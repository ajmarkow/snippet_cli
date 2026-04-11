# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/wizard_helpers/validation_loop'

class ValidationLoopTestHost
  include SnippetCli::WizardHelpers::ValidationLoop

  public :prompt_until_valid, :prompt_non_empty
end

RSpec.describe SnippetCli::WizardHelpers::ValidationLoop do
  subject(:host) { ValidationLoopTestHost.new }

  describe '#prompt_until_valid' do
    it 'returns the value immediately when the block yields [value, nil]' do
      result = host.prompt_until_valid { ['hello', nil] }
      expect(result).to eq('hello')
    end

    it 'loops until the block yields a nil error' do
      calls = 0
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      result = host.prompt_until_valid do
        calls += 1
        calls < 3 ? ['bad', 'too short'] : ['good', nil]
      end
      expect(result).to eq('good')
      expect(calls).to eq(3)
    end

    it 'calls UI.transient_warning with the error message on each invalid attempt' do
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      host.prompt_until_valid do |_|
        @done ||= false
        if @done
          ['ok', nil]
        else
          @done = true
          ['', 'cannot be empty']
        end
      end
      expect(SnippetCli::UI).to have_received(:transient_warning).with('cannot be empty').once
    end

    it 'calls the clear lambda from the previous iteration before re-prompting' do
      cleared = false
      clear_lambda = -> { cleared = true }
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(clear_lambda)
      calls = 0
      host.prompt_until_valid do
        calls += 1
        calls == 1 ? ['', 'error'] : ['ok', nil]
      end
      expect(cleared).to be(true)
    end

    context 'when the block yields a callable error (confirm-and-retry pattern)' do
      it 'does not call UI.transient_warning — uses the callable directly as clear' do
        allow(SnippetCli::UI).to receive(:transient_warning)
        calls = 0
        host.prompt_until_valid do
          calls += 1
          calls < 2 ? ['bad', -> {}] : ['good', nil]
        end
        expect(SnippetCli::UI).not_to have_received(:transient_warning)
      end

      it 'loops until the block yields a nil error' do
        calls = 0
        result = host.prompt_until_valid do
          calls += 1
          calls < 3 ? ['bad', -> {}] : ['good', nil]
        end
        expect(result).to eq('good')
        expect(calls).to eq(3)
      end

      it 'calls the callable clear from the previous iteration' do
        cleared = false
        calls = 0
        host.prompt_until_valid do
          calls += 1
          calls == 1 ? ['bad', -> { cleared = true }] : ['good', nil]
        end
        expect(cleared).to be(true)
      end
    end
  end

  describe '#prompt_non_empty' do
    it 'returns the value when the block yields a non-empty string' do
      result = host.prompt_non_empty('cannot be empty') { 'hello' }
      expect(result).to eq('hello')
    end

    it 'loops and shows a transient warning when the block yields an empty string' do
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      calls = 0
      result = host.prompt_non_empty('cannot be empty') do
        calls += 1
        calls < 2 ? '' : 'hello'
      end
      expect(result).to eq('hello')
      expect(SnippetCli::UI).to have_received(:transient_warning).with('cannot be empty').once
    end

    it 'treats whitespace-only input as empty' do
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      calls = 0
      host.prompt_non_empty('msg') do
        calls += 1
        calls < 2 ? '   ' : 'ok'
      end
      expect(SnippetCli::UI).to have_received(:transient_warning).once
    end
  end
end
