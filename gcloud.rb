#!/usr/bin/env ruby

require 'yaml'

CONFIG_FILE = './config.yml'
File.exists?(CONFIG_FILE) || File.write(CONFIG_FILE, YAML.dump({}))

def config
  YAML.load(File.read(CONFIG_FILE))
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

def init_tooling
  puts "\n·  (Re-)Creating containers..."
  system(%Q{ docker-compose down 2> /dev/null }) || exit(1)
  system(%Q{ docker-compose up   2> /dev/null }) || exit(1)
end

AUTH_COMMAND="gcloud auth login"
LIST_COMMAND="gcloud auth list 2> /dev/null | grep \\*"
def init_gcloud_auth
  puts "\n·  Authenticating with Google Cloud..."
  system(%Q{ docker-compose run --rm app sh -c "(#{LIST_COMMAND}) || ((#{AUTH_COMMAND}) && (#{LIST_COMMAND}))" }) || exit(1)

  set(:last_auth, Time.now.to_i)
end

def init_gcloud_project
  get(:last_auth) || init_gcloud_auth

  unless (project_id = get(:project_id))
    puts "\n·  Projects:"
    system(%Q{ docker-compose run --rm app gcloud projects list }) || exit(1)

    print "Project ID: "
    project_id = gets.chomp

    set(:project_id, project_id)
  end

  puts "\n·  Setting your active project to #{project_id} ..."
  system(%Q{ docker-compose run --rm app gcloud config set project #{project_id} }) || exit(1)
end

def init_k8s_cluster
  unless (project_id = get(:project_id))
    init_gcloud_project
    project_id = get(:project_id)
  end

  unless (cluster_name = get(:cluster_name) && cluster_region = get(:cluster_region))
    puts "\n·  Kubernetes Clusters:"
    system(%Q{ docker-compose run --rm app gcloud container clusters list }) || exit(1)

    print "Cluster name: "
    cluster_name = gets.chomp
    print "Cluster location: "
    cluster_region = gets.chomp

    set(:cluster_name, cluster_name)
    set(:cluster_region, cluster_region)
  end

  puts "\n·  Connecting to the #{cluster_name} cluster..."
  system(%Q{ docker-compose run --rm app gcloud container clusters get-credentials #{cluster_name} --region #{cluster_region} --project #{project_id} }) || exit(1)
end

def init_k8s_namespace
  get(:cluster_name) || init_k8s_cluster

  unless (namespace_name = get(:namespace_name))
    puts "\n·  Available Kubernetes namespaces:"
    system(%Q{ docker-compose run --rm app kubectl get namespaces }) || exit(1)

    print "Namespace: "
    namespace_name = gets.chomp

    set(:namespace_name, namespace_name)
  end
end

def init_k8s_pods
  namespace_name = get(:namespace_name) || init_k8s_namespace

  unless (pod_id = get(:pod_id))
    puts "\n·  Getting pods from #{namespace_name} ..."
    system(%Q{ docker-compose run --rm app kubectl get pods -n #{namespace_name} | grep web-kiosk-foreground }) || exit(1)

    print "Pod ID: "
    pod_id = gets.chomp

    set(:pod_id, pod_id)
  end
end

def connect_to_pod
  namespace_name = get(:namespace_name) || init_k8s_namespace
  pod_id = get(:pod_id) || init_k8s_pods

  puts "\n·  Connecting to pod: #{pod_id} ..."
  system(%Q{ docker-compose run --rm app sh -c "kubectl exec -it #{pod_id} -n #{namespace_name} -c puma bash" }) || exit(1)
end

init_tooling && connect_to_pod