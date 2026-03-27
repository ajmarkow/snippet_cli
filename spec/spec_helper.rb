# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))

require 'aruba/rspec'
require 'dry/cli'
require 'snippet_cli'

Aruba.configure do |config|
  config.command_search_paths = ['exe']
  config.exit_timeout = 15
  config.activate_announcer_on_command_failure = %i[stdout stderr]
end
