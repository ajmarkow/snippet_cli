# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/trigger_resolver'
require 'snippet_cli/wizard_helpers'

# Minimal host class for exercising the module in isolation.
class TriggerResolverHost
  include SnippetCli::TriggerResolver
  include SnippetCli::WizardHelpers

  public :prompt_trigger_loop
  public :collect_triggers
end

RSpec.describe SnippetCli::TriggerResolver do
  subject(:host) { TriggerResolverHost.new }

  describe '#collect_triggers' do
    context 'when type is regex' do
      before do
        allow(host).to receive(:prompt_non_empty_trigger).and_return(':(gr|great)ing')
        allow(host).to receive(:check_conflicts)
      end

      it 'displays UI.info with Rust Regex syntax guidance' do
        expect(SnippetCli::UI).to receive(:info).with(a_string_including('Espanso uses Rust Regex syntax'))
        host.collect_triggers('regex', nil, false)
      end

      it 'displays UI.info with link to Rust regex docs' do
        expect(SnippetCli::UI).to receive(:info).with(a_string_including('https://docs.rs/regex/1.1.8/regex/#syntax'))
        host.collect_triggers('regex', nil, false)
      end

      it 'displays UI.info before prompting for input' do
        order = []
        allow(SnippetCli::UI).to receive(:info) { order << :info }
        allow(host).to receive(:prompt_non_empty_trigger) do
          order << :prompt
          ':(gr|great)ing'
        end
        host.collect_triggers('regex', nil, false)
        expect(order).to eq(%i[info prompt])
      end
    end

    context 'when type is regular' do
      before do
        allow(host).to receive(:collect_regular_triggers).and_return([[':foo'], false])
      end

      it 'does not display the Rust Regex guidance' do
        expect(SnippetCli::UI).not_to receive(:info).with(a_string_including('Rust Regex'))
        host.collect_triggers('regular', nil, false)
      end
    end
  end

  describe '#prompt_trigger_loop' do
    context 'when user enters one trigger and declines to add another' do
      before do
        allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':foo')
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another trigger?'))
          .and_return(false)
        allow($stdout).to receive(:puts)
        allow(SnippetCli::UI).to receive(:info)
      end

      it 'displays UI.info with multi-trigger guidance on first prompt' do
        expect(SnippetCli::UI).to receive(:info).with(a_string_including('Multiple triggers can share one replacement'))
        host.prompt_trigger_loop
      end

      it 'displays UI.info only once (not on subsequent iterations)' do
        count = 0
        allow(SnippetCli::UI).to receive(:info) { count += 1 }
        host.prompt_trigger_loop
        expect(count).to eq(1)
      end

      it 'returns the single trigger' do
        expect(host.prompt_trigger_loop).to eq([':foo'])
      end

      it 'includes current triggers table in the confirm prompt' do
        expect(Gum).to receive(:confirm).with(a_string_including(':foo')).and_return(false)
        host.prompt_trigger_loop
      end

      it 'includes "Current triggers:" label in the confirm prompt' do
        expect(Gum).to receive(:confirm).with(a_string_including('Current triggers:')).and_return(false)
        host.prompt_trigger_loop
      end
    end

    context 'when user adds two triggers then declines' do
      before do
        allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':foo', ':bar')
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another trigger?'))
          .and_return(true, false)
        allow($stdout).to receive(:puts)
        allow(SnippetCli::UI).to receive(:info)
      end

      it 'returns both triggers' do
        expect(host.prompt_trigger_loop).to eq([':foo', ':bar'])
      end

      it 'shows all collected triggers in the second confirm prompt' do
        prompts = []
        allow(Gum).to receive(:confirm) do |text|
          prompts << text
          prompts.size < 2
        end
        host.prompt_trigger_loop
        expect(prompts.last).to include(':foo')
        expect(prompts.last).to include(':bar')
      end
    end
  end
end
