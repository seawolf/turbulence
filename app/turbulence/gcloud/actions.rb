# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      LIST = [
        ConnectToContainer,
        AttachToContainer,
        TailLogsSingleContainer,
        TailLogsAllContainers,
        RestartDeployment,
        DestroyNamespace
      ].freeze
    end
  end
end
