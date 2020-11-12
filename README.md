# Turbulence

Tools to help you connect to Google Cloud pods.

### Rationale

You can point you web browser to https://console.cloud.google.com and click your way to your
cloud-deployed servers. You've probably done that before you've contrived the arguably particular
commands (providing you installed Python, the Google CLoud SDK and kubectl on your own computer).

If you wanted something simpler than that, just something to get you to the command prompt you're
otherwise used to, then this may help.

### Usage

##### Prerequisites

* Docker & Docker Compose

##### Invocation

```
./gcloud.rb
```

Ths will:

1. download and install the Google Cloud SDK into a Docker container, so you need not install it
2. authenticate with Google Cloud, so you can access your GCloud stuff
3. show your GCloud projects, so you can pick the one you want
4. show the K8S clusters in that project, so you can pick the one you want
4. show the K8S namespaces in that cluster, so you can pick the one you want
5. show the K8S pods in that cluster, so you can pick the one you want
6. connect to your pod, so you can do what you wanted to do.

At each stage, information entered will be stored for the next time.

To ask for the information again, delete the value from `config.yml`.

### TODOs

* provide more commands to allow steps to be repeated without editing config.yml
