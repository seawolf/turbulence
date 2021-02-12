#!/usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Naming/AccessorMethodName

require_relative './lib/menu'

require 'yaml'

CONFIG_FILE = './config.yml'
AUTH_COMMAND = 'gcloud auth login'
LIST_COMMAND = 'gcloud auth list 2> /dev/null | grep \\*'
SUGGESTED_COMMANDS = [
  '/bin/bash',
  '/bin/sh',
  'bundle exec rails console',
  'bundle exec irb',

  { name: '(other)', value: nil }
].freeze

def config
  YAML.load(File.read(CONFIG_FILE)) || {} # rubocop:disable Security/YAMLLoad
end

def config!(data)
  File.write(CONFIG_FILE, YAML.dump(data))
  data
end

def get(key)
  config[key]
end

def set(key, value)
  data = config
  data[key] = value
  config!(data)
  value
end

def init_config? # rubocop:disable Metrics/MethodLength
  if (project_id = get(:project_id)) &&
     (namespace_name = get(:namespace_name)) &&
     (cluster_name = get(:cluster_name)) &&
     (cluster_region = get(:cluster_region))
    PROMPT.say <<~ENDOFMSG
      ·  You have previously run this to connect to:
         · project: #{project_id}
         · cluster: #{cluster_name} [#{cluster_region}]
         · namespace: #{namespace_name}
    ENDOFMSG

    choices = [
      { name: 'Yes', value: false },
      { name: 'No', value: true }
    ]
    return menu_auto_select('Would you like to keep this selection?', choices)
  end

  true
end

def init_config!
  File.write(CONFIG_FILE, YAML.dump({}))
end

def auth_with_gcloud
  PROMPT.say("\n·  Authenticating with Google Cloud...")
  system(%{ (#{LIST_COMMAND}) || ((#{AUTH_COMMAND}) && (#{LIST_COMMAND})) }) || exit(1)

  set(:last_auth, Time.now.to_i)
end

Project = Struct.new(:id, :name)
def get_gcloud_project # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  get(:last_auth) || auth_with_gcloud

  unless (project_id = get(:project_id))
    projects_list = `gcloud projects list --format="value(projectId, name)"` || exit(1)
    projects = projects_list.split("\n").map do |line|
      segments = line.split(/\s+/)
      Project.new(segments[0], segments[1..-1].join(' '))
    end

    choices = projects.map do |project|
      {
        name: "#{project.name} (#{project.id})",
        value: project
      }
    end

    project = menu_auto_select('Projects in your Google Cloud:', choices, per_page: choices.length)
    project_id = set(:project_id, project.id)
  end

  PROMPT.say("\nSelecting the project \"#{project_id}\" as active...")
  system(%( gcloud config set project #{project_id} 1> /dev/null )) || exit(1)

  project_id
end

Cluster = Struct.new(:name, :region)
def get_k8s_cluster # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  unless (project_id = get(:project_id))
    get_gcloud_project
    project_id = get(:project_id)
  end

  unless (cluster_name = get(:cluster_name) && cluster_region = get(:cluster_region))
    clusters_list = `gcloud container clusters list --format="value(name, zone)"` || exit(1)
    clusters = clusters_list.split("\n").map do |line|
      segments = line.split(/\s+/)
      Cluster.new(*segments)
    end

    choices = clusters.map do |cluster|
      {
        name: "#{cluster.name} (#{cluster.region})",
        value: cluster
      }
    end

    raise "No Kubernetes clusters in the #{project_id} project! (It may be only a Cloud Run project.)" if choices.empty?

    cluster = menu_auto_select("Kubernetes clusters in the \"#{project_id}\" project:", choices, per_page: choices.length)

    cluster_name = set(:cluster_name, cluster.name)
    cluster_region = set(:cluster_region, cluster.region)
  end

  PROMPT.say("\n·  Connecting to the #{cluster_name} cluster...")
  system(%( gcloud container clusters get-credentials #{cluster_name} --region #{cluster_region} --project #{project_id} 1> /dev/nulls)) || exit(1)

  [cluster_name, cluster_region]
end

Namespace = Struct.new(:name)
def get_k8s_namespace # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  cluster_name = get(:cluster_name) || get_k8s_cluster[0]
  namespace_name = get(:namespace_name)

  return namespace_name if namespace_name

  namespaces_list = `kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}'` || exit(1)
  namespaces = namespaces_list.split("\n").map do |line|
    Namespace.new(line)
  end

  choices = namespaces.map do |namespace|
    {
      name: namespace.name,
      value: namespace
    }
  end

  raise "No Kubernetes namespaces in the #{cluster_name} cluster!" if choices.empty?

  namespace = menu_auto_select("Kubernetes namespaces in the \"#{cluster_name}\" cluster:", choices, per_page: choices.length)
  namespace_name = set(:namespace_name, namespace.name)

  set(:namespace_name, namespace_name)
end

Pod = Struct.new(:id)
def get_k8s_pods # rubocop:disable Metrics/MethodLength
  namespace_name = get(:namespace_name) || get_k8s_namespace

  pods_list = `kubectl get pods -n #{namespace_name} -o jsonpath='{range .items[*]}{.metadata.name}{"\\n"}{end}' | grep foreground` || exit(1)
  pods = pods_list.split("\n").map do |line|
    Pod.new(line)
  end

  choices = pods.map do |pod|
    {
      name: pod.id,
      value: pod
    }
  end

  raise "No Kubernetes pods in the #{namespace_name} namespace!" if choices.empty?

  pod = menu_auto_select("Pods in the \"#{namespace_name}\" namespace:", choices, per_page: choices.length)
  set(:pod_id, pod.id)
end

Container = Struct.new(:name)
def get_k8s_container # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  namespace_name = get(:namespace_name) || get_k8s_namespace
  pod_id = get(:pod_id) || get_k8s_pods

  containers_list = `kubectl get pods -n #{namespace_name} #{pod_id} -o jsonpath='{range .spec.containers[*]}{.name}{"\\n"}{end}'` || exit(1)
  containers = containers_list.split("\n").map do |line|
    Container.new(line)
  end

  choices = containers.map do |container|
    {
      name: container.name,
      value: container
    }
  end

  raise "No containers in the #{pod_id} pod!" if choices.empty?

  container = menu_auto_select("Containers in the \"#{pod_id}\" pod:", choices, per_page: choices.length)
  set(:container_name, container.name)
end

def connect_to_container
  namespace_name = get(:namespace_name) || get_k8s_namespace
  pod_id = get_k8s_pods
  container_name = get_k8s_container

  command =
    PROMPT.select('Command to run:', SUGGESTED_COMMANDS, per_page: SUGGESTED_COMMANDS.length) ||
    PROMPT.ask('Command to run:', required: true)

  PROMPT.ok("\nConnecting...\n")
  system(%( kubectl exec -it #{pod_id} -n #{namespace_name} -c #{container_name} -- #{command} ))
end

if File.exist?(CONFIG_FILE)
  init_config? && init_config!
else
  init_config!
end

# rubocop:enable all

auth_with_gcloud && connect_to_container
