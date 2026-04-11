# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/wizard_helpers/prompt_helpers'

class PromptHelpersTestHost
  include SnippetCli::WizardHelpers::PromptHelpers

  public :confirm!, :list_confirm!, :optional_prompt, :prompt!
end

RSpec.describe SnippetCli::WizardHelpers::PromptHelpers do
  subject(:host) { PromptHelpersTestHost.new }

  before { system('true') } # reset $? so stale 130 exits don't fire WizardInterrupted

  describe '#prompt!' do
    it 'returns the value when non-nil' do
      expect(host.prompt!('hello')).to eq('hello')
    end

    it 'raises WizardInterrupted when value is nil' do
      expect { host.prompt!(nil) }.to raise_error(SnippetCli::WizardInterrupted)
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
end
