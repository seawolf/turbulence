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
end

def init_gcloud_project
  puts "\n·  Projects:"
  system(%Q{ docker-compose run --rm app gcloud projects list }) || exit(1)

  print "Project ID: "
  $project_id = gets.chomp

  puts "\n·  Setting your active project to #{$project_id} ..."
  system(%Q{ docker-compose run --rm app gcloud config set project #{$project_id} }) || exit(1)
end

def init_k8s_cluster
  puts "\n·  Kubernetes Clusters:"
  system(%Q{ docker-compose run --rm app gcloud container clusters list }) || exit(1)

  print "Cluster name: "
  cluster_name = gets.chomp
  print "Cluster location: "
  cluster_region = gets.chomp

  puts "\n·  Connecting to the #{cluster_name} cluster..."
  system(%Q{ docker-compose run --rm app gcloud container clusters get-credentials #{cluster_name} --region #{cluster_region} --project #{$project_id} }) || exit(1)
end

def init_k8s_namespace
  puts "\n·  Available Kubernetes namespaces:"
  system(%Q{ docker-compose run --rm app kubectl get namespaces }) || exit(1)

  print "Namespace: "
  $namespace_name = gets.chomp
end

def init_k8s_pods
  puts "\n·  Getting pods from #{$namespace_name} ..."
  system(%Q{ docker-compose run --rm app kubectl get pods -n #{$namespace_name} | grep web-kiosk-foreground }) || exit(1)

  print "Pod ID: "
  pod_id = gets.chomp

  puts "\n·  Connecting to pod: #{pod_id} ..."
  system(%Q{ docker-compose run --rm app sh -c "kubectl exec -it #{pod_id} -n #{$namespace_name} -c puma bash" }) || exit(1)
end

init_tooling
init_gcloud_auth
init_gcloud_project
init_k8s_cluster
init_k8s_namespace
init_k8s_pods
