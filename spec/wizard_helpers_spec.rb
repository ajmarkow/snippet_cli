# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/wizard_helpers'

class WizardHelpersTestHost
  include SnippetCli::WizardHelpers

  public :confirm!
end

RSpec.describe SnippetCli::WizardHelpers do
  subject(:host) { WizardHelpersTestHost.new }

  before { system('true') } # reset $? so stale 130 exits don't fire WizardInterrupted

  describe '#confirm!' do
    it 'passes prompt_style with a double border to Gum.confirm' do
      allow(Gum).to receive(:confirm).and_return(true)
      host.confirm!('Are you sure?')
      expect(Gum).to have_received(:confirm)
        .with('Are you sure?', prompt_style: a_hash_including(border: 'double'))
    end

    it 'does not pass --border-foreground 075 via prompt_style for accent color' do
      allow(Gum).to receive(:confirm).and_return(true)
      host.confirm!('Are you sure?')
      expect(Gum).to have_received(:confirm)
        .with('Are you sure?', prompt_style: a_hash_including('border-foreground': '075'))
    end

    it 'passes padding via prompt_style' do
      allow(Gum).to receive(:confirm).and_return(true)
      host.confirm!('Are you sure?')
      expect(Gum).to have_received(:confirm)
        .with('Are you sure?', prompt_style: a_hash_including(padding: '0 1'))
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
