# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require 'spec_helper'

RSpec.describe 'snippet_cli binary', type: :aruba do
  context 'banner' do
    before { run_command_and_stop('snippet_cli version') }

    it 'displays the ASCII banner on every invocation' do
      expect(last_command_stopped).to have_output(/┏━┓┏┓╻╻/)
    end

    it 'displays a double-line box border' do
      expect(last_command_stopped).to have_output(/╔═+╗/)
    end
  end

  context 'version command' do
    before { run_command_and_stop('snippet_cli version') }

    it 'exits successfully' do
      expect(last_command_stopped).to be_successfully_executed
    end

    it 'prints the version in a double-line box' do
      expect(last_command_stopped).to have_output(/║.*VERSION \d+\.\d+\.\d+.*║/)
    end
  end

  context 'conflict command' do
    let(:fixture_path) { File.expand_path('../fixtures/duplicate_triggers.yml', __dir__) }

    context 'with no arguments' do
      before { run_command_and_stop('snippet_cli conflict', fail_on_error: false) }

      it 'exits non-zero' do
        expect(last_command_stopped.exit_status).not_to eq(0)
      end
    end

    context 'with a non-existent file' do
      before { run_command_and_stop('snippet_cli conflict nonexistent.yml', fail_on_error: false) }

      it 'exits non-zero' do
        expect(last_command_stopped.exit_status).not_to eq(0)
      end

      it 'prints an error message' do
        expect(last_command_stopped).to have_output(/not found|No such file/i)
      end
    end

    context 'with the fixture file (has duplicates)' do
      before { run_command_and_stop("snippet_cli conflict #{fixture_path}", fail_on_error: false) }

      it 'completes without a Ruby exception' do
        expect(last_command_stopped).not_to have_output(/Error:|exception/i)
      end
    end

    context 'with the fixture file and a known trigger' do
      before { run_command_and_stop("snippet_cli conflict #{fixture_path} :hello", fail_on_error: false) }

      it 'completes without a Ruby exception' do
        expect(last_command_stopped).not_to have_output(/Error:|exception/i)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
