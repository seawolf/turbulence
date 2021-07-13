# frozen_string_literal: true

require 'zeitwerk'

Dir.glob('lib/**/*.rb').sort.map do |f|
  require_relative f
end

Zeitwerk::Loader.new.tap do |loader|
  loader.push_dir('app')

  loader.inflector.inflect 'gcloud' => 'GCloud'

  loader.enable_reloading
  loader.setup
  loader.eager_load
end
