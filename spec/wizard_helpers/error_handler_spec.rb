# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/wizard_helpers/error_handler'

class ErrorHandlerTestHost
  include SnippetCli::WizardHelpers::ErrorHandler

  public :handle_errors
end

RSpec.describe SnippetCli::WizardHelpers::ErrorHandler do
  subject(:host) { ErrorHandlerTestHost.new }

  let(:test_error_class) { Class.new(StandardError) }

  describe '#handle_errors' do
    it 'executes the block' do
      executed = false
      host.handle_errors { executed = true }
      expect(executed).to be(true)
    end

    it 'returns the block value' do
      expect(host.handle_errors { 42 }).to eq(42)
    end

    context 'when WizardInterrupted is raised' do
      before { allow(SnippetCli::UI).to receive(:error) }

      it 'outputs a blank line to stdout' do
        expect { host.handle_errors { raise SnippetCli::WizardInterrupted } }
          .to output("\n").to_stdout
      end

      it 'calls UI.error with the interrupted message' do
        host.handle_errors { raise SnippetCli::WizardInterrupted }
        expect(SnippetCli::UI).to have_received(:error).with(/Interrupted.*exiting snippet_cli/i)
      end

      it 'does not exit' do
        expect { host.handle_errors { raise SnippetCli::WizardInterrupted } }.not_to raise_error
      end
    end

    context 'when a specified error class is raised' do
      before { allow(SnippetCli::UI).to receive(:error) }

      it 'calls UI.error with the exception message' do
        expect { host.handle_errors(test_error_class) { raise test_error_class, 'something broke' } }
          .to raise_error(SystemExit)
        expect(SnippetCli::UI).to have_received(:error).with('something broke')
      end

      it 'exits with status 1' do
        expect { host.handle_errors(test_error_class) { raise test_error_class, 'oops' } }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end
    end

    context 'when multiple error classes are specified' do
      let(:other_error_class) { Class.new(StandardError) }

      before { allow(SnippetCli::UI).to receive(:error) }

      it 'rescues any of the specified classes' do
        expect { host.handle_errors(test_error_class, other_error_class) { raise other_error_class, 'err' } }
          .to raise_error(SystemExit)
        expect(SnippetCli::UI).to have_received(:error).with('err')
      end
    end

    context 'when an unspecified error is raised' do
      it 'propagates the error' do
        expect { host.handle_errors(test_error_class) { raise ArgumentError, 'unrelated' } }
          .to raise_error(ArgumentError, 'unrelated')
      end
    end
  end
end
