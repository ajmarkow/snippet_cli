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
  public :resolve_triggers
  public :resolve_triggers_from_flags
  public :resolve_triggers_interactively
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

  describe '#validate_trigger_flags!' do
    it 'raises InvalidFlagsError when --trigger and --triggers are both provided' do
      expect { host.send(:validate_trigger_flags!, ':foo', ':bar,:baz', nil) }
        .to raise_error(SnippetCli::InvalidFlagsError, /mutually exclusive/i)
    end

    it 'raises InvalidFlagsError when all three flags are provided' do
      expect { host.send(:validate_trigger_flags!, ':foo', ':bar', 'regex') }
        .to raise_error(SnippetCli::InvalidFlagsError, /mutually exclusive/i)
    end

    it 'does not raise when only one flag is provided' do
      expect { host.send(:validate_trigger_flags!, ':foo', nil, nil) }.not_to raise_error
    end

    it 'does not raise when no flags are provided' do
      expect { host.send(:validate_trigger_flags!, nil, nil, nil) }.not_to raise_error
    end
  end

  describe '#check_conflicts' do
    let(:fixture_path) { File.join(__dir__, 'fixtures', 'duplicate_triggers.yml') }

    it 'raises TriggerConflictError when a trigger already exists and no_warn is false' do
      expect { host.send(:check_conflicts, [':hello'], fixture_path, false) }
        .to raise_error(SnippetCli::TriggerConflictError, /:hello/)
    end

    it 'does not raise when no_warn is true' do
      expect { host.send(:check_conflicts, [':hello'], fixture_path, true) }.not_to raise_error
    end

    it 'does not raise when no conflicts exist' do
      expect { host.send(:check_conflicts, [':no_such_trigger'], fixture_path, false) }.not_to raise_error
    end

    it 'does not raise when file does not exist' do
      expect { host.send(:check_conflicts, [':hello'], '/nonexistent.yml', false) }.not_to raise_error
    end
  end

  describe 'TriggerResolution struct' do
    it 'is defined under SnippetCli::TriggerResolver' do
      expect(SnippetCli::TriggerResolver::TriggerResolution).to be_a(Class)
    end

    it 'has named fields: list, is_regex, single_trigger' do
      r = SnippetCli::TriggerResolver::TriggerResolution.new([':foo'], false, true)
      expect(r.list).to eq([':foo'])
      expect(r.is_regex).to be(false)
      expect(r.single_trigger).to be(true)
    end
  end

  describe '#resolve_triggers_from_flags' do
    before { allow(host).to receive(:check_conflicts) }

    context 'with --trigger flag' do
      let(:opts) { { trigger: ':foo', triggers: nil, regex: nil, file: nil, no_warn: false } }

      it 'returns a TriggerResolution struct' do
        result = host.resolve_triggers_from_flags(opts)
        expect(result).to be_a(SnippetCli::TriggerResolver::TriggerResolution)
      end

      it 'has list containing the trigger' do
        expect(host.resolve_triggers_from_flags(opts).list).to eq([':foo'])
      end

      it 'has is_regex false' do
        expect(host.resolve_triggers_from_flags(opts).is_regex).to be(false)
      end

      it 'has single_trigger true' do
        expect(host.resolve_triggers_from_flags(opts).single_trigger).to be(true)
      end
    end

    context 'with --regex flag' do
      let(:opts) { { trigger: nil, triggers: nil, regex: ':(gr|great)ing', file: nil, no_warn: false } }

      it 'returns a TriggerResolution struct with is_regex true' do
        result = host.resolve_triggers_from_flags(opts)
        expect(result).to be_a(SnippetCli::TriggerResolver::TriggerResolution)
        expect(result.is_regex).to be(true)
        expect(result.single_trigger).to be(false)
      end
    end
  end

  describe '#resolve_triggers_interactively' do
    before do
      allow(Gum).to receive(:choose).and_return('regular')
      allow(host).to receive(:prompt!).and_return('regular')
      allow(host).to receive(:collect_triggers).and_return([[':foo'], false])
    end

    it 'returns a TriggerResolution struct' do
      result = host.resolve_triggers_interactively({})
      expect(result).to be_a(SnippetCli::TriggerResolver::TriggerResolution)
    end

    it 'has single_trigger false (interactive never produces single)' do
      result = host.resolve_triggers_interactively({})
      expect(result.single_trigger).to be(false)
    end

    it 'has list and is_regex from collect_triggers' do
      result = host.resolve_triggers_interactively({})
      expect(result.list).to eq([':foo'])
      expect(result.is_regex).to be(false)
    end
  end

  describe '#prompt_trigger_loop' do
    context 'when user enters one trigger and declines to add another' do
      before do
        allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':foo')
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another trigger?'), prompt_style: anything)
          .and_return(false)
        allow($stdout).to receive(:puts)
        allow(SnippetCli::UI).to receive(:info)
      end

      it 'passes multi-trigger guidance as header to Gum.input on first prompt' do
        expect(Gum).to receive(:input)
          .with(hash_including(
                  placeholder: ':trigger',
                  header: a_string_including('Multiple triggers can share one replacement')
                ))
          .and_return(':foo')
        host.prompt_trigger_loop
      end

      it 'does not call UI.info for trigger guidance (guidance is in input header)' do
        expect(SnippetCli::UI).not_to receive(:info)
        host.prompt_trigger_loop
      end

      it 'returns the single trigger' do
        expect(host.prompt_trigger_loop).to eq([':foo'])
      end

      it 'includes current triggers table in the confirm prompt' do
        expect(Gum).to receive(:confirm).with(a_string_including(':foo'), prompt_style: anything).and_return(false)
        host.prompt_trigger_loop
      end

      it 'includes "Current triggers:" label in the confirm prompt' do
        expect(Gum).to receive(:confirm).with(a_string_including('Current triggers:'),
                                              prompt_style: anything).and_return(false)
        host.prompt_trigger_loop
      end
    end

    context 'when user adds two triggers then declines' do
      before do
        allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':foo', ':bar')
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another trigger?'), prompt_style: anything)
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
