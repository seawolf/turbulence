#!/usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Naming/AccessorMethodName

require 'yaml'

CONFIG_FILE = './config.yml'
AUTH_COMMAND = 'gcloud auth login'
LIST_COMMAND = 'gcloud auth list 2> /dev/null | grep \\*'

def config
  YAML.load(File.read(CONFIG_FILE)) # rubocop:disable Security/YAMLLoad
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

def init_container
  puts "\n·  (Re-)Creating containers..."
  system(%( docker-compose down 2> /dev/null )) || exit(1)
  system(%( docker-compose up   2> /dev/null )) || exit(1)
end

def init_config? # rubocop:disable Metrics/MethodLength
  if (project_id = get(:project_id)) &&
     (namespace_name = get(:namespace_name)) &&
     (cluster_name = get(:cluster_name)) &&
     (cluster_region = get(:cluster_region))
    msg = <<~ENDOFMSG
      ·  You have previously run this to connect to:
         · project: #{project_id}
         · cluster: #{cluster_name} [#{cluster_region}]
         · namespace: #{namespace_name}

    ENDOFMSG
    puts msg
    print 'Would you like to keep this selection (y/n)? '
    choice = gets.chomp.downcase

    return choice != 'y' && choice != ''
  end

  true
end

def init_config!
  File.write(CONFIG_FILE, YAML.dump({}))
end

def auth_with_gcloud
  puts "\n·  Authenticating with Google Cloud..."
  system(%{ docker-compose run --rm app sh -c "(#{LIST_COMMAND}) || ((#{AUTH_COMMAND}) && (#{LIST_COMMAND}))" }) || exit(1)

  set(:last_auth, Time.now.to_i)
end

def get_gcloud_project
  get(:last_auth) || auth_with_gcloud

  unless (project_id = get(:project_id))
    puts "\n·  Projects:"
    system(%( docker-compose run --rm app gcloud projects list )) || exit(1)

    print 'Project ID: '
    project_id = gets.chomp

    set(:project_id, project_id)
  end

  puts "\n·  Selecting the project \"#{project_id}\" as active..."
  system(%( docker-compose run --rm app gcloud config set project #{project_id} )) || exit(1)

  return project_id
end

def get_k8s_cluster # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  unless (project_id = get(:project_id))
    get_gcloud_project
    project_id = get(:project_id)
  end

  unless (cluster_name = get(:cluster_name) && cluster_region = get(:cluster_region))
    puts "\n·  Kubernetes clusters in the \"#{project_id}\" project:"
    system(%( docker-compose run --rm app gcloud container clusters list )) || exit(1)

    print 'Cluster Name: '
    cluster_name = gets.chomp
    print 'Cluster Location: '
    cluster_region = gets.chomp

    set(:cluster_name, cluster_name)
    set(:cluster_region, cluster_region)
  end

  puts "\n·  Connecting to the #{cluster_name} cluster..."
  system(%( docker-compose run --rm app gcloud container clusters get-credentials #{cluster_name} --region #{cluster_region} --project #{project_id} )) || exit(1)

  return cluster_name, cluster_region
end

def get_k8s_namespace
  cluster_name = get(:cluster_name) || get_k8s_cluster[0]
  namespace_name = get(:namespace_name)

  return namespace_name if namespace_name

  puts "\n·  Kubernetes namespaces in the \"#{cluster_name}\" cluster:"
  system(%( docker-compose run --rm app kubectl get namespaces )) || exit(1)

  print 'Namespace Name: '
  namespace_name = gets.chomp

  set(:namespace_name, namespace_name)
end

def get_k8s_pods
  namespace_name = get(:namespace_name) || get_k8s_namespace

  puts "\n·  Pods in the \"#{namespace_name}\" namespace:"
  system(%( docker-compose run --rm app kubectl get pods -n #{namespace_name} | grep foreground )) || exit(1)

  print 'Pod ID: '
  pod_id = gets.chomp

  set(:pod_id, pod_id)
end

def get_k8s_container
  namespace_name = get(:namespace_name) || get_k8s_namespace
  pod_id = get(:pod_id) || get_k8s_pods

  puts "\n·  Containers in the \"#{pod_id}\" pod:"
  system(%( docker-compose run --rm app kubectl get pods -n #{namespace_name} #{pod_id} -o jsonpath='{range .items[*]}{range .spec.containers[*]}{"   · "}{.name}{"\\n"}{end}' )) || exit(1)

  print 'Container: '
  container_name = gets.chomp

  set(:container_name, container_name)
end

def connect_to_container
  namespace_name = get(:namespace_name) || get_k8s_namespace
  pod_id = get_k8s_pods
  container_name = get_k8s_container

  puts "\n·  Connecting to container \"#{container_name}\" in pod: #{pod_id} ..."
  system(%( docker-compose run --rm app sh -c "kubectl exec -it #{pod_id} -n #{namespace_name} -c #{container_name} bash" )) || exit(1)
end

if File.exist?(CONFIG_FILE)
  init_config? && init_config!
else
  init_config!
end

# rubocop:enable all

init_container && auth_with_gcloud && connect_to_container
