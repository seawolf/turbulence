#!/bin/bash -e

function init_tooling {
  echo ""; echo "·  (Re-)Creating containers..."
  docker-compose down 2> /dev/null || true
  docker-compose up   2> /dev/null
}

function init_gcloud_auth {
  echo ""; echo "·  Authenticating with Google Cloud..."
  auth_command="gcloud auth login"
  list_command="gcloud auth list 2> /dev/null | grep \*"
  docker-compose run --rm app sh -c "($list_command) || (($auth_command) && ($list_command))"
}

function init_gcloud_project {
  echo "" ; echo "·  Projects:"
  docker-compose run --rm app gcloud projects list

  echo -n "Project ID: "
  read project_id

  echo "" ; echo "·  Setting your active project to $project_id ..."
  docker-compose run --rm app gcloud config set project $project_id
}

function init_k8s_cluster {
  echo "" ; echo "·  Kubernetes Clusters:"
  docker-compose run --rm app gcloud container clusters list

  echo -n "Cluster name: "
  read cluster_name
  echo -n "Cluster location: "
  read cluster_region

  echo "" ; echo "·  Connecting to the $cluster_name cluster..."
  docker-compose run --rm app gcloud container clusters get-credentials $cluster_name --region $cluster_region --project $project_id
}

function init_k8s_namespace {
  echo "" ; echo "·  Available Kubernetes namespaces:"
  docker-compose run --rm app kubectl get namespaces

  echo -n "Namespace: "
  read namespace_name
}

function init_k8s_pods {
  echo "" ; echo "·  Getting pods from $namespace_name ..."
  docker-compose run --rm app kubectl get pods -n $namespace_name | grep web-kiosk-foreground

  echo -n "Pod ID: "
  read pod_id

  echo "" ; echo "·  Connecting to pod: $pod_id ..."
  docker-compose run --rm app sh -c "kubectl exec -it $pod_id -n $namespace_name -c puma bash"
}

init_tooling
init_gcloud_auth
init_gcloud_project
init_k8s_cluster
init_k8s_namespace
init_k8s_pods

