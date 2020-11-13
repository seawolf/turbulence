#!/usr/bin/env ruby

require 'yaml'

CONFIG_FILE = './config.yml'
AUTH_COMMAND="gcloud auth login"
LIST_COMMAND="gcloud auth list 2> /dev/null | grep \\*"

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

def init_container
  puts "\n·  (Re-)Creating containers..."
  system(%Q{ docker-compose down 2> /dev/null }) || exit(1)
  system(%Q{ docker-compose up   2> /dev/null }) || exit(1)
end

def init_config?
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
    print "Would you like to keep this selection (y/n)? "
    choice = gets.chomp.downcase

    return choice != 'y' && choice != ''
  end

  return true
end

def init_config!
  File.write(CONFIG_FILE, YAML.dump({}))
end

def auth_with_gcloud
  puts "\n·  Authenticating with Google Cloud..."
  system(%Q{ docker-compose run --rm app sh -c "(#{LIST_COMMAND}) || ((#{AUTH_COMMAND}) && (#{LIST_COMMAND}))" }) || exit(1)

  set(:last_auth, Time.now.to_i)
end

def get_gcloud_project
  get(:last_auth) || auth_with_gcloud

  unless (project_id = get(:project_id))
    puts "\n·  Projects:"
    system(%Q{ docker-compose run --rm app gcloud projects list }) || exit(1)

    print "Project ID: "
    project_id = gets.chomp

    set(:project_id, project_id)
  end

  puts "\n·  Selecting the project \"#{project_id}\" as active..."
  system(%Q{ docker-compose run --rm app gcloud config set project #{project_id} }) || exit(1)
end

def get_k8s_cluster
  unless (project_id = get(:project_id))
    get_gcloud_project
    project_id = get(:project_id)
  end

  unless (cluster_name = get(:cluster_name) && cluster_region = get(:cluster_region))
    puts "\n·  Kubernetes clusters in the \"#{project_id}\" project:"
    system(%Q{ docker-compose run --rm app gcloud container clusters list }) || exit(1)

    print "Cluster Name: "
    cluster_name = gets.chomp
    print "Cluster Location: "
    cluster_region = gets.chomp

    set(:cluster_name, cluster_name)
    set(:cluster_region, cluster_region)
  end

  puts "\n·  Connecting to the #{cluster_name} cluster..."
  system(%Q{ docker-compose run --rm app gcloud container clusters get-credentials #{cluster_name} --region #{cluster_region} --project #{project_id} }) || exit(1)
end

def get_k8s_namespace
  get(:cluster_name) || get_k8s_cluster

  unless (namespace_name = get(:namespace_name))
    puts "\n·  Kubernetes namespaces in the \"#{cluster_name}\" cluster:"
    system(%Q{ docker-compose run --rm app kubectl get namespaces }) || exit(1)

    print "Namespace Name: "
    namespace_name = gets.chomp

    set(:namespace_name, namespace_name)
  end
end

def get_k8s_pods
  namespace_name = get(:namespace_name) || get_k8s_namespace

  puts "\n·  Pods in the \"#{namespace_name}\" namespace:"
  system(%Q{ docker-compose run --rm app kubectl get pods -n #{namespace_name} | grep web-kiosk-foreground }) || exit(1)

  print "Pod ID: "
  pod_id = gets.chomp

  set(:pod_id, pod_id)
end

def connect_to_pod
  namespace_name = get(:namespace_name) || get_k8s_namespace
  pod_id = get_k8s_pods  # always list pods, as they change frequently

  puts "\n·  Connecting to pod: #{pod_id} ..."
  system(%Q{ docker-compose run --rm app sh -c "kubectl exec -it #{pod_id} -n #{namespace_name} -c puma bash" }) || exit(1)
end

if File.exists?(CONFIG_FILE)
  init_config? && init_config!
else
  init_config!
end

init_container && auth_with_gcloud && connect_to_pod