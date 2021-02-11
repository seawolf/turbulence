#!/usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Naming/AccessorMethodName

require 'yaml'
require 'tty-prompt'

CONFIG_FILE = './config.yml'
AUTH_COMMAND = 'gcloud auth login'
LIST_COMMAND = 'gcloud auth list 2> /dev/null | grep \\*'

PROMPT = TTY::Prompt.new

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
    puts <<~ENDOFMSG
      ·  You have previously run this to connect to:
         · project: #{project_id}
         · cluster: #{cluster_name} [#{cluster_region}]
         · namespace: #{namespace_name}
    ENDOFMSG

    return PROMPT.select("Would you like to keep this selection?") do |menu|
      menu.choice 'Yes', false
      menu.choice 'No', true
    end
  end

  true
end

def init_config!
  File.write(CONFIG_FILE, YAML.dump({}))
end

def auth_with_gcloud
  puts "\n·  Authenticating with Google Cloud..."
  system(%{ (#{LIST_COMMAND}) || ((#{AUTH_COMMAND}) && (#{LIST_COMMAND})) }) || exit(1)

  set(:last_auth, Time.now.to_i)
end

Project = Struct.new(:id, :number, :name)
def get_gcloud_project
  get(:last_auth) || auth_with_gcloud

  unless (project_id = get(:project_id))
    projects_list = `gcloud projects list` || exit(1)
    projects = projects_list.split("\n").each_with_index.inject([]) do |list, (line, index)|
      next list if index == 0

      segments = line.gsub(/\s/, ' ').split(' ')
      list.push Project.new(segments[0], segments[-1], segments[1..-2].join(' '))
    end

    choices = projects.map do |project|
      {
        name: "#{project.name} (#{project.id})",
        value: project
      }
    end

    project = PROMPT.select("\n·  Projects in your Google Cloud:", choices, per_page: choices.length)
    project_id = set(:project_id, project.id)
  end

  puts "\n·  Selecting the project \"#{project_id}\" as active..."
  system(%( gcloud config set project #{project_id} )) || exit(1)

  project_id
end

Cluster = Struct.new(:name, :region)
def get_k8s_cluster # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  unless (project_id = get(:project_id))
    get_gcloud_project
    project_id = get(:project_id)
  end

  unless (cluster_name = get(:cluster_name) && cluster_region = get(:cluster_region))
    clusters_list = `gcloud container clusters list` || exit(1)
    clusters = clusters_list.split("\n").each_with_index.inject([]) do |list, (line, index)|
      next list if index == 0

      segments = line.gsub(/\s/, ' ').split(' ')[0..1]
      list.push Cluster.new(*segments)
    end

    choices = clusters.map do |cluster|
      {
        name: "#{cluster.name} (#{cluster.region})",
        value: cluster
      }
    end

    cluster = PROMPT.select("\n·  Kubernetes clusters in the \"#{project_id}\" project:", choices, per_page: choices.length)

    cluster_name = set(:cluster_name, cluster .name)
    cluster_region = set(:cluster_region, cluster.region)
  end

  puts "\n·  Connecting to the #{cluster_name} cluster..."
  system(%( gcloud container clusters get-credentials #{cluster_name} --region #{cluster_region} --project #{project_id} )) || exit(1)

  [cluster_name, cluster_region]
end

Namespace = Struct.new(:name, :age)
def get_k8s_namespace
  cluster_name = get(:cluster_name) || get_k8s_cluster[0]
  namespace_name = get(:namespace_name)

  return namespace_name if namespace_name

  namespaces_list = `kubectl get namespaces` || exit(1)
  namespaces = namespaces_list.split("\n").each_with_index.inject([]) do |list, (line, index)|
    next list if index == 0

    segments = line.gsub(/\s/, ' ').split(' ')
    list.push Namespace.new(segments[0], segments[-1])
  end

  choices = namespaces.map do |namespace|
    {
      name: "#{namespace.name} (#{namespace.age}) old",
      value: namespace
    }
  end

  namespace = PROMPT.select("\n·  Kubernetes namespaces in the \"#{cluster_name}\" cluster:", choices, per_page: choices.length)
  namespace_name = set(:namespace_name, namespace.name)

  set(:namespace_name, namespace_name)
end

Pod = Struct.new(:id)
def get_k8s_pods
  namespace_name = get(:namespace_name) || get_k8s_namespace

  pods_list = `kubectl get pods -n #{namespace_name} | grep foreground` || exit(1)
  pods = pods_list.split("\n").inject([]) do |list, line|
    segments = line.gsub(/\s/, ' ').split(' ')[0..0]
    list.push Pod.new(segments[0])
  end

  choices = pods.map do |pod|
    {
      name: pod.id,
      value: pod
    }
  end

  pod = PROMPT.select("\n·  Pods in the \"#{namespace_name}\" namespace:", choices, per_page: choices.length)
  pod_id = set(:pod_id, pod.id)
end

Container = Struct.new(:name)
def get_k8s_container
  namespace_name = get(:namespace_name) || get_k8s_namespace
  pod_id = get(:pod_id) || get_k8s_pods

  containers_list = `kubectl get pods -n #{namespace_name} #{pod_id} -o jsonpath='{range .spec.containers[*]}{.name}{"\\n"}{end}'` || exit(1)
  containers = containers_list.split("\n").inject([]) do |list, line|
    segments = line.gsub(/\s/, ' ').split(' ')[0..0]
    list.push Container.new(segments[0])
  end

  choices = containers.map do |container|
    {
      name: container.name,
      value: container
    }
  end

  container = PROMPT.select("\n·  Containers in the \"#{pod_id}\" pod:", choices, per_page: choices.length)
  container_name = set(:container_name, container.name)
end

def connect_to_container
  namespace_name = get(:namespace_name) || get_k8s_namespace
  pod_id = get_k8s_pods
  container_name = get_k8s_container

  puts "\n·  Connecting to container \"#{container_name}\" in pod: #{pod_id} ...\n"
  system(%( kubectl exec -it #{pod_id} -n #{namespace_name} -c #{container_name} -- bash ))
end

if File.exist?(CONFIG_FILE)
  init_config? && init_config!
else
  init_config!
end

# rubocop:enable all

auth_with_gcloud && connect_to_container
