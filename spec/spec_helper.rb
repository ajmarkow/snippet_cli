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

RSpec.configure do |config|
  # Reset $? before each example so that stale exit statuses from prior
  # tests don't trigger the Ctrl+C detection ($?.exitstatus == 130) in
  # confirm! wrappers when Gum.confirm is stubbed.
  config.before(:each) { system('true') }
end
