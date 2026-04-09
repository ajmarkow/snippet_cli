# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/wizard_helpers'

class WizardHelpersTestHost
  include SnippetCli::WizardHelpers

  public :confirm!
  public :handle_errors
  public :optional_prompt
end

RSpec.describe SnippetCli::WizardHelpers do
  subject(:host) { WizardHelpersTestHost.new }

  before { system('true') } # reset $? so stale 130 exits don't fire WizardInterrupted

  describe '#optional_prompt' do
    context 'when the user confirms' do
      before { allow(Gum).to receive(:confirm).and_return(true) }

      it 'returns the block result' do
        result = host.optional_prompt('Add one?') { 'collected value' }
        expect(result).to eq('collected value')
      end

      it 'executes the block' do
        executed = false
        host.optional_prompt('Add one?') { executed = true }
        expect(executed).to be(true)
      end
    end

    context 'when the user declines' do
      before { allow(Gum).to receive(:confirm).and_return(false) }

      it 'returns nil' do
        result = host.optional_prompt('Add one?') { 'collected value' }
        expect(result).to be_nil
      end

      it 'does not execute the block' do
        executed = false
        host.optional_prompt('Add one?') { executed = true }
        expect(executed).to be(false)
      end
    end
  end

  describe '#handle_errors' do
    let(:test_error_class) { Class.new(StandardError) }

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

  describe '#confirm!' do
    it 'does not include a border in prompt_style' do
      allow(Gum).to receive(:confirm).and_return(true)
      host.confirm!('Are you sure?')
      expect(Gum).to have_received(:confirm)
        .with('Are you sure?', prompt_style: hash_not_including(:border))
    end

    it 'does not include a border-foreground color in prompt_style' do
      allow(Gum).to receive(:confirm).and_return(true)
      host.confirm!('Are you sure?')
      expect(Gum).to have_received(:confirm)
        .with('Are you sure?', prompt_style: hash_not_including(:'border-foreground'))
    end

    it 'passes padding via prompt_style' do
      allow(Gum).to receive(:confirm).and_return(true)
      host.confirm!('Are you sure?')
      expect(Gum).to have_received(:confirm)
        .with('Are you sure?', prompt_style: a_hash_including(padding: '0 1'))
    end

    it 'overrides the default left margin to zero via prompt_style' do
      allow(Gum).to receive(:confirm).and_return(true)
      host.confirm!('Are you sure?')
      expect(Gum).to have_received(:confirm)
        .with('Are you sure?', prompt_style: a_hash_including(margin: '0'))
    end

    it 'returns true when Gum.confirm returns true' do
      allow(Gum).to receive(:confirm).and_return(true)
      expect(host.confirm!('Proceed?')).to be true
    end

    it 'returns false when Gum.confirm returns false' do
      allow(Gum).to receive(:confirm).and_return(false)
      expect(host.confirm!('Proceed?')).to be false
    end

    it 'raises WizardInterrupted when Gum.confirm returns nil' do
      allow(Gum).to receive(:confirm).and_return(nil)
      expect { host.confirm!('Proceed?') }.to raise_error(SnippetCli::WizardInterrupted)
    end
  end
end
