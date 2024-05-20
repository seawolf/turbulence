# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      LIST = [
        ConnectToContainer,
        AttachToContainer,
        TailLogsSingleContainer,
        TailLogsAllContainers,
        ForwardPort,
        DownloadFile,
        RestartDeployment,
        DestroyNamespace
      ].freeze
    end
  end
end
