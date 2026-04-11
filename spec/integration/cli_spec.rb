# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'snippet_cli binary', type: :aruba do
  context 'banner' do
    before { run_command_and_stop('snippet_cli version') }

    it 'displays the ASCII banner even when stdout is not a tty (UI redirected to stderr)' do
      expect(last_command_stopped).to have_output(/┏━┓┏┓╻╻/)
    end

    it 'displays a rounded border' do
      expect(last_command_stopped).to have_output(/╭─+╮/)
    end
  end

  context 'version command' do
    before { run_command_and_stop('snippet_cli version') }

    it 'exits successfully' do
      expect(last_command_stopped).to be_successfully_executed
    end

    it 'prints the version in a rounded box' do
      expect(last_command_stopped).to have_output(/\d+\.\d+\.\d+/)
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
      before { run_command_and_stop('snippet_cli conflict --file nonexistent.yml', fail_on_error: false) }

      it 'exits non-zero' do
        expect(last_command_stopped.exit_status).not_to eq(0)
      end

      it 'prints an error message' do
        expect(last_command_stopped).to have_output(/not found|No such file/i)
      end
    end

    context 'with the fixture file (has duplicates)' do
      before { run_command_and_stop("snippet_cli conflict --file #{fixture_path}", fail_on_error: false) }

      it 'completes without a Ruby exception' do
        expect(last_command_stopped).not_to have_output(/Error:|exception/i)
      end
    end

    context 'with the fixture file and a known trigger' do
      before do
        cmd = "snippet_cli conflict --file #{fixture_path} --trigger :hello"
        run_command_and_stop(cmd, fail_on_error: false)
      end

      it 'completes without a Ruby exception' do
        expect(last_command_stopped).not_to have_output(/Error:|exception/i)
      end
    end

    context 'with alias c' do
      before { run_command_and_stop("snippet_cli c --file #{fixture_path}", fail_on_error: false) }

      it 'completes without a Ruby exception' do
        expect(last_command_stopped).not_to have_output(/Error:|exception/i)
      end
    end

    context 'with multiple triggers' do
      before do
        cmd = "snippet_cli conflict --file #{fixture_path} --trigger :hello --trigger :bye"
        run_command_and_stop(cmd, fail_on_error: false)
      end

      it 'completes without a Ruby exception' do
        expect(last_command_stopped).not_to have_output(/Error:|exception/i)
      end
    end
  end
end
