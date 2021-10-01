# frozen_string_literal: true

module Turbulence
  module GCloud
    module Actions
      LIST = [
        ConnectToContainer,
        TailLogsSingleContainer,
        TailLogsAllContainers,
        RestartDeployment,
        DestroyNamespace
      ].freeze
    end
  end
end
