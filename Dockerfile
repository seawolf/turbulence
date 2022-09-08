# match the Ruby version with GitHub Actions workflow:
FROM ruby:3.0.0-slim

EXPOSE 25863

WORKDIR /usr/src

#####
# Install Google Cloud SDK
#####

RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3

RUN curl https://sdk.cloud.google.com > /tmp/install-gcloud &&\
    chmod +x /tmp/install-gcloud &&\
    bash /tmp/install-gcloud --disable-prompts

#####
# Configure Google Cloud SDK
#####

RUN echo "source /root/google-cloud-sdk/completion.bash.inc" >> /root/.bashrc
RUN echo "source /root/google-cloud-sdk/path.bash.inc" >> /root/.bashrc
RUN echo "export USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> /root/.bashrc
RUN bash -lc "gcloud components install kubectl gke-gcloud-auth-plugin"

#####
# Configure Ruby and co.
#####

# Configure Bundler to not install extra fluff with gems
RUN echo 'gem: --no-document' > /etc/gemrc
RUN gem install bundler

COPY Gemfile Gemfile.lock /usr/src/
RUN bundle install

COPY app /usr/src/
COPY config.yml /usr/src
ENTRYPOINT ["bash", "-lc", "bundle exec ruby turbulence.rb"]
