# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/new_workflow'

RSpec.describe SnippetCli::NewWorkflow do
  subject(:workflow) { described_class.new }

  before { allow($stdout).to receive(:tty?).and_return(true) }

  def stub_gum_preview
    allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
      input.to_s
    end
    allow(Gum::Command).to receive(:run_display_only).and_return(true)
  end

  def stub_happy_path(trigger: ':test', replace: 'Test replacement')
    stub_trigger_prompts(trigger: trigger)
    stub_replace_prompts(replace: replace)
    allow(SnippetCli::VarBuilder).to receive(:run).and_return({ vars: [], summary_clear: -> {} })
    stub_gum_preview
  end

  def stub_confirm_false(message)
    allow(Gum).to receive(:confirm).with(message, prompt_style: anything).and_return(false)
  end

  def stub_trigger_prompts(trigger: ':test')
    allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
    allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(trigger)
    stub_confirm_false(a_string_including('Add another trigger?'))
  end

  def stub_replace_prompts(replace: 'Test replacement')
    stub_confirm_false('Alternative (non-plaintext) replacement type?')
    stub_confirm_false('Multi-line replacement?')
    allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return(replace)
    stub_confirm_false('Add a label?')
    stub_confirm_false('Add a comment?')
    stub_confirm_false('Add search terms?')
  end

  describe '#run' do
    it 'completes a basic wizard run without error' do
      stub_happy_path
      expect { workflow.run({}) }.not_to raise_error
    end

    it 'calls summary_clear before delivering output' do
      summary_clear = double('clear', call: nil)
      stub_happy_path
      # Override VarBuilder stub set by stub_happy_path with our trackable double
      allow(SnippetCli::VarBuilder).to receive(:run).and_return({ vars: [], summary_clear: summary_clear })

      workflow.run({})

      expect(summary_clear).to have_received(:call)
    end

    it 'does not call GlobalVarsWriter or MatchFileWriter when save_path is absent' do
      stub_happy_path
      allow(SnippetCli::MatchFileWriter).to receive(:append)
      allow(SnippetCli::GlobalVarsWriter).to receive(:read_names)

      workflow.run({})

      expect(SnippetCli::MatchFileWriter).not_to have_received(:append)
      expect(SnippetCli::GlobalVarsWriter).not_to have_received(:read_names)
    end

    context 'when user adds search terms' do
      before do
        stub_trigger_prompts
        stub_confirm_false('Alternative (non-plaintext) replacement type?')
        stub_confirm_false('Multi-line replacement?')
        allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('hello')
        stub_confirm_false('Add a label?')
        stub_confirm_false('Add a comment?')
        allow(SnippetCli::VarBuilder).to receive(:run).and_return({ vars: [], summary_clear: -> {} })
        stub_gum_preview
        allow(Gum).to receive(:confirm).with('Add search terms?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:input).with(placeholder: 'search term (blank to finish)')
                                     .and_return('ruby', 'array', '')
      end

      it 'passes search_terms to SnippetBuilder' do
        allow(SnippetCli::SnippetBuilder).to receive(:build).and_call_original
        allow($stdout).to receive(:puts)
        workflow.run({})
        expect(SnippetCli::SnippetBuilder).to have_received(:build)
          .with(hash_including(search_terms: %w[ruby array]))
      end
    end

    context 'when --replace is provided (skip wizard replacement flow)' do
      it 'does not invoke VarBuilder' do
        allow(SnippetCli::VarBuilder).to receive(:run)
        stub_gum_preview
        allow(Gum).to receive(:choose).and_return('regular')
        allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another trigger?'), prompt_style: anything).and_return(false)

        workflow.run(trigger: ':test', replace: 'Hello')

        expect(SnippetCli::VarBuilder).not_to have_received(:run)
      end
    end
  end
end
