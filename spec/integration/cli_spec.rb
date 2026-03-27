# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'snippet_cli binary', type: :aruba do
  context 'version command' do
    before { run_command_and_stop('snippet_cli version') }

    it 'exits successfully' do
      expect(last_command_stopped).to be_successfully_executed
    end

    it 'prints the version' do
      expect(last_command_stopped).to have_output(/\d+\.\d+\.\d+/)
    end
  end
end
