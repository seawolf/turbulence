#!/bin/bash -e

function init_tooling {
  echo ""; echo "·  (Re-)Creating containers..."
  docker-compose down 2> /dev/null || true
  docker-compose up   2> /dev/null
}

function init_gcloud_auth {
  echo ""; echo "·  Authenticating with Google Cloud..."
  AUTH_COMMAND="gcloud auth login"
  LIST_COMMAND="gcloud auth list 2> /dev/null | grep \*"
  docker-compose run --rm app sh -c "($LIST_COMMAND) || (($AUTH_COMMAND) && ($LIST_COMMAND))"
}

function init_gcloud_project {
  echo "" ; echo "·  Projects:"
  docker-compose run --rm app gcloud projects list

  echo -n "Project ID: "
  read PROJECT_ID

  echo "" ; echo "·  Setting your active project to $PROJECT_ID ..."
  docker-compose run --rm app gcloud config set project $PROJECT_ID
}

function init_k8s_cluster {
  echo "" ; echo "·  Kubernetes Clusters:"
  docker-compose run --rm app gcloud container clusters list

  echo -n "Cluster name: "
  read CLUSTER_NAME
  echo -n "Cluster location: "
  read CLUSTER_REGION

  echo "" ; echo "·  Connecting to the $CLUSTER_NAME cluster..."
  docker-compose run --rm app gcloud container clusters get-credentials $CLUSTER_NAME --region $CLUSTER_REGION --project $PROJECT_ID
}

function init_k8s_namespace {
  echo "" ; echo "·  Available Kubernetes namespaces:"
  docker-compose run --rm app kubectl get namespaces

  echo -n "Namespace: "
  read NAMESPACE_NAME
}

function init_k8s_pods {
  echo "" ; echo "·  Getting pods from $NAMESPACE_NAME ..."
  docker-compose run --rm app kubectl get pods -n $NAMESPACE_NAME | grep web-kiosk-foreground

  echo -n "Pod ID: "
  read POD_ID

  echo "" ; echo "·  Connecting to pod: $POD_ID ..."
  docker-compose run --rm app sh -c "kubectl exec -it $POD_ID -n $NAMESPACE_NAME -c puma bash"
}

# init_tooling
# init_gcloud_auth
init_gcloud_project
init_k8s_cluster
init_k8s_namespace
init_k8s_pods

