# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  coverage_dir 'spec/coverage'
  track_files 'app/**/*.rb'
  add_filter 'spec'
end
