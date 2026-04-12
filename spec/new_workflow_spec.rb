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
    allow(Gum).to receive(:choose).with('regular', 'regex',
                                        hash_including(header: "Trigger type?\n")).and_return('regular')
    allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(trigger)
    stub_confirm_false(a_string_including('Add another trigger?'))
  end

  def stub_replace_prompts(replace: 'Test replacement')
    stub_confirm_false('Alternative (non-plaintext) replacement type?')
    stub_confirm_false('Multi-line replacement?')
    allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return(replace)
    stub_confirm_false('Show advanced options?')
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

    context 'when user declines advanced options' do
      before do
        stub_trigger_prompts
        stub_confirm_false('Alternative (non-plaintext) replacement type?')
        stub_confirm_false('Multi-line replacement?')
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return('hello')
        allow(SnippetCli::VarBuilder).to receive(:run).and_return({ vars: [], summary_clear: -> {} })
        stub_gum_preview
        stub_confirm_false('Show advanced options?')
      end

      it 'does not prompt for label, comment, search terms, word, or propagate_case' do
        allow($stdout).to receive(:puts)
        workflow.run({})
        expect(Gum).not_to have_received(:confirm).with('Add a label?', anything)
        expect(Gum).not_to have_received(:confirm).with('Add a comment?', anything)
        expect(Gum).not_to have_received(:confirm).with('Add search terms?', anything)
        expect(Gum).not_to have_received(:confirm).with('Word trigger?', anything)
        expect(Gum).not_to have_received(:confirm).with('Propagate case?', anything)
      end

      it 'passes nil label and comment and empty search_terms to SnippetBuilder' do
        allow(SnippetCli::SnippetBuilder).to receive(:build).and_call_original
        allow($stdout).to receive(:puts)
        workflow.run({})
        expect(SnippetCli::SnippetBuilder).to have_received(:build)
          .with(hash_including(label: nil, comment: nil, search_terms: []))
      end
    end

    context 'when user accepts advanced options and adds search terms' do
      before do
        stub_trigger_prompts
        stub_confirm_false('Alternative (non-plaintext) replacement type?')
        stub_confirm_false('Multi-line replacement?')
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return('hello')
        stub_confirm_false('Add a label?')
        stub_confirm_false('Add a comment?')
        stub_confirm_false('Word trigger?')
        stub_confirm_false('Propagate case?')
        allow(SnippetCli::VarBuilder).to receive(:run).and_return({ vars: [], summary_clear: -> {} })
        stub_gum_preview
        allow(Gum).to receive(:confirm).with('Show advanced options?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with('Add search terms?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:write).with(hash_including(header: 'Put one search term per line'))
                                     .and_return("ruby\narray")
      end

      it 'passes search_terms to SnippetBuilder' do
        allow(SnippetCli::SnippetBuilder).to receive(:build).and_call_original
        allow($stdout).to receive(:puts)
        workflow.run({})
        expect(SnippetCli::SnippetBuilder).to have_received(:build)
          .with(hash_including(search_terms: %w[ruby array]))
      end
    end

    context 'when user enables word and propagate_case in advanced options' do
      before do
        stub_trigger_prompts
        stub_confirm_false('Alternative (non-plaintext) replacement type?')
        stub_confirm_false('Multi-line replacement?')
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return('hello')
        stub_confirm_false('Add a label?')
        stub_confirm_false('Add a comment?')
        stub_confirm_false('Add search terms?')
        allow(SnippetCli::VarBuilder).to receive(:run).and_return({ vars: [], summary_clear: -> {} })
        stub_gum_preview
        allow(Gum).to receive(:confirm).with('Show advanced options?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with('Word trigger?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with('Propagate case?', prompt_style: anything).and_return(true)
      end

      it 'passes word: true and propagate_case: true to SnippetBuilder' do
        allow(SnippetCli::SnippetBuilder).to receive(:build).and_call_original
        allow($stdout).to receive(:puts)
        workflow.run({})
        expect(SnippetCli::SnippetBuilder).to have_received(:build)
          .with(hash_including(word: true, propagate_case: true))
      end
    end

    context 'when --bare flag is used' do
      before do
        stub_trigger_prompts
        stub_confirm_false('Multi-line replacement?')
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return('hello')
        stub_gum_preview
      end

      it 'does not prompt for advanced options' do
        allow($stdout).to receive(:puts)
        workflow.run({ bare: true })
        expect(Gum).not_to have_received(:confirm).with('Show advanced options?', anything)
      end
    end

    context 'when --no-vars flag is used' do
      before do
        stub_trigger_prompts
        stub_confirm_false('Alternative (non-plaintext) replacement type?')
        stub_confirm_false('Multi-line replacement?')
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return('hello')
        stub_confirm_false('Show advanced options?')
        stub_gum_preview
      end

      it 'does not invoke VarBuilder' do
        allow(SnippetCli::VarBuilder).to receive(:run)
        allow($stdout).to receive(:puts)
        workflow.run({ no_vars: true })
        expect(SnippetCli::VarBuilder).not_to have_received(:run)
      end

      it 'passes vars: [] to SnippetBuilder' do
        allow(SnippetCli::SnippetBuilder).to receive(:build).and_call_original
        allow($stdout).to receive(:puts)
        workflow.run({ no_vars: true })
        expect(SnippetCli::SnippetBuilder).to have_received(:build)
          .with(hash_including(vars: []))
      end

      it 'still prompts for alternative replacement type' do
        alt_prompt = 'Alternative (non-plaintext) replacement type?'
        allow(Gum).to receive(:confirm).with(alt_prompt, prompt_style: anything)
        allow($stdout).to receive(:puts)
        workflow.run({ no_vars: true })
        expect(Gum).to have_received(:confirm).with(alt_prompt, prompt_style: anything)
      end

      it 'still prompts for advanced options' do
        allow(Gum).to receive(:confirm).with('Show advanced options?', prompt_style: anything)
        allow($stdout).to receive(:puts)
        workflow.run({ no_vars: true })
        expect(Gum).to have_received(:confirm).with('Show advanced options?', prompt_style: anything)
      end
    end
  end
end
