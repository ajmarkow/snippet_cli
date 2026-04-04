# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/commands/new'

RSpec.describe SnippetCli::Commands::New do
  subject(:command) { described_class.new }

  let(:fixture_path) { File.join(__dir__, '..', 'fixtures', 'duplicate_triggers.yml') }

  before { allow($stdout).to receive(:tty?).and_return(true) }

  # Shared Gum stubs for a minimal happy-path run.
  # Split into focused helpers so each stays under the method-length threshold.
  def stub_happy_path(trigger_type: 'regular', trigger: ':test', replace: 'Test replacement')
    stub_trigger_prompts(trigger_type: trigger_type, trigger: trigger)
    stub_replace_prompts(replace: replace)
    stub_gum_preview
    allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
  end

  def stub_confirm_false(message)
    allow(Gum).to receive(:confirm).with(message, prompt_style: anything).and_return(false)
  end

  def stub_trigger_prompts(trigger_type: 'regular', trigger: ':test')
    allow(Gum).to receive(:choose)
      .with('regular', 'regex', header: "Trigger type?\n").and_return(trigger_type)
    allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(trigger)
    stub_confirm_false(a_string_including('Add another trigger?'))
  end

  def stub_replace_prompts(replace: 'Test replacement')
    stub_confirm_false('Alternative (non-plaintext) replacement type?')
    stub_confirm_false('Multi-line replacement?')
    allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return(replace)
    stub_post_replace_prompts
  end

  def stub_post_replace_prompts
    stub_confirm_false('Add a label?')
    stub_confirm_false('Add a comment?')
  end

  def stub_gum_preview
    allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
      input.to_s
    end
    allow(Gum::Command).to receive(:run_display_only).and_return(true)
  end

  def capture_display_input
    captured = []
    allow(Gum::Command).to receive(:run_display_only) do |*, input: nil, **|
      captured << input.to_s
      true
    end
    captured
  end

  context 'basic wizard run (no-clipboard, no file)' do
    before { stub_happy_path }

    it 'renders "Snippet YAML below." via UI.info' do
      allow(SnippetCli::UI).to receive(:info)
      command.call
      expect(SnippetCli::UI).to have_received(:info).with('Snippet YAML below.')
    end

    it 'syntax-highlights the YAML output via Gum::Command.run_display_only' do
      allow(Gum::Command).to receive(:run_display_only).and_return(true)
      command.call
      expect(Gum::Command).to have_received(:run_display_only)
        .with('format', '--type=code', '--language=yaml', input: anything)
    end

    it 'passes YAML containing triggers to display' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/triggers/)
    end

    it 'passes the entered trigger value to display' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/':test'|":test"/)
    end

    it 'passes the replacement text to display' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/Test replacement/)
    end
  end

  context 'regex trigger type' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regex')
      allow(Gum).to receive(:input).with(placeholder: 'r"^(hello|bye)$"').and_return('(gr|great)ing')
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hello')
      allow(Gum).to receive(:confirm).with('Add a label?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?', prompt_style: anything).and_return(false)

      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
    end

    it 'passes YAML with regex: key to display' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/regex:/)
    end

    it 'does not include triggers: key in the YAML' do
      captured = capture_display_input
      command.call
      expect(captured.join).not_to include('triggers:')
    end
  end

  context 'with label and comment' do
    before do
      stub_happy_path
      allow(Gum).to receive(:confirm).with('Add a label?', prompt_style: anything).and_return(true)
      allow(Gum).to receive(:input).with(placeholder: 'Label').and_return('My label')
      allow(Gum).to receive(:confirm).with('Add a comment?', prompt_style: anything).and_return(true)
      allow(Gum).to receive(:input).with(placeholder: 'Comment').and_return('My comment')
    end

    it 'includes the label' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/label:/)
    end

    it 'includes the comment' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/comment:/)
    end
  end

  context 'schema validation failure' do
    before do
      stub_happy_path
      allow(SnippetCli::SnippetBuilder).to receive(:build)
        .and_raise(SnippetCli::ValidationError, "Schema validation failed:\n  - bad field")
    end

    it 'renders the error message via UI.error' do
      allow(SnippetCli::UI).to receive(:error)
      expect { command.call }.to raise_error(SystemExit)
      expect(SnippetCli::UI).to have_received(:error).with(/Schema validation failed/)
    end

    it 'exits with status 1' do
      allow(SnippetCli::UI).to receive(:info)
      expect { command.call }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  context 'conflict detection with --file' do
    before do
      stub_happy_path(trigger: ':hello') # :hello exists in fixture
    end

    it 'warns about the conflicting trigger and exits 1' do
      expect do
        command.call(file: fixture_path)
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/Warning.*:hello/i).to_stderr
    end
  end

  context 'conflict detection with --no-warn' do
    before do
      stub_happy_path(trigger: ':hello') # :hello exists in fixture
    end

    it 'does not exit when --no-warn is set' do
      expect do
        command.call(file: fixture_path, no_warn: true)
      end.not_to raise_error
    end
  end

  context 'Ctrl+C interrupt during wizard' do
    before do
      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
    end

    it 'exits immediately with interrupted message when Gum.choose returns nil (Ctrl+C at first prompt)' do
      allow(Gum).to receive(:choose).and_return(nil)

      expect { command.call }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
    end

    it 'does not call any further Gum prompts after Gum.choose returns nil' do
      allow(Gum).to receive(:choose).and_return(nil)
      allow(Gum).to receive(:input)
      allow(Gum).to receive(:confirm)

      expect { command.call }.to output(anything).to_stdout
      expect(Gum).not_to have_received(:input)
      expect(Gum).not_to have_received(:confirm)
    end

    it 'exits immediately with interrupted message when Gum.input returns nil mid-wizard (Ctrl+C at trigger input)' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(nil)
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?'),
                                           prompt_style: anything).and_return(false)

      expect { command.call }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
    end

    it 'exits immediately with interrupted message when Gum.input returns nil at replace prompt' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?'),
                                           prompt_style: anything).and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return(nil)

      expect { command.call }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
    end

    it 'does not call SnippetBuilder when interrupted at replace prompt' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?'),
                                           prompt_style: anything).and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return(nil)
      allow(SnippetCli::SnippetBuilder).to receive(:build)

      expect { command.call }.to output(anything).to_stdout
      expect(SnippetCli::SnippetBuilder).not_to have_received(:build)
    end

    it 'exits immediately when Ctrl+C on Gum.confirm (exit code 130) at "Add another trigger?"' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?'), prompt_style: anything) do
        # Simulate system() setting $? to exit 130 (Ctrl+C)
        system('exit 130')
        false
      end
      allow(SnippetCli::VarBuilder).to receive(:run)

      expect { command.call }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
      expect(SnippetCli::VarBuilder).not_to have_received(:run)
    end

    it 'exits immediately when Ctrl+C on Gum.confirm (exit code 130) at "Multi-line replacement?"' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?'),
                                           prompt_style: anything).and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything) do
        system('exit 130')
        false
      end
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text')

      expect { command.call }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
      expect(Gum).not_to have_received(:input).with(placeholder: 'Replacement text')
    end
  end

  context 'multiple regular triggers' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':hello', ':hi')
      allow(Gum).to receive(:confirm)
        .with(a_string_including('Add another trigger?'), prompt_style: anything)
        .and_return(true, false)
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hey!')
      allow(Gum).to receive(:confirm).with('Add a label?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?', prompt_style: anything).and_return(false)

      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
    end

    it 'includes both triggers' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/':hello'|":hello"/)
    end
  end

  # ── CLI trigger flags (TASK-3) ──────────────────────────────────────────────

  context '--trigger flag with --replace (skip wizard entirely)' do
    it 'emits YAML with singular trigger: key' do
      captured = capture_display_input
      command.call(trigger: ':ty', replace: 'Thank you')
      expect(captured.join).to match(/trigger: ":ty"/)
    end

    it 'does not emit triggers: array key' do
      captured = capture_display_input
      command.call(trigger: ':ty', replace: 'Thank you')
      expect(captured.join).not_to include('triggers:')
    end

    it 'does not invoke any Gum prompts' do
      allow(Gum).to receive(:choose)
      allow(Gum).to receive(:input)
      allow(Gum).to receive(:confirm)

      command.call(trigger: ':ty', replace: 'Thank you')

      expect(Gum).not_to have_received(:choose)
      expect(Gum).not_to have_received(:input)
      expect(Gum).not_to have_received(:confirm)
    end
  end

  context '--triggers flag with --replace' do
    it 'emits YAML with triggers: array containing both values' do
      captured = capture_display_input
      command.call(triggers: ':ty,:thankyou', replace: 'Thank you')
      expect(captured.join).to include('triggers:')
      expect(captured.join).to match(/':ty'|":ty"/)
      expect(captured.join).to match(/':thankyou'|":thankyou"/)
    end
  end

  context '--regex flag with --replace' do
    it 'emits YAML with regex: key' do
      captured = capture_display_input
      command.call(regex: '\bty\b', replace: 'Thank you')
      expect(captured.join).to include('regex:')
      expect(captured.join).not_to include('triggers:')
      expect(captured.join).not_to include('trigger:')
    end
  end

  context 'no trigger flags provided' do
    before { stub_happy_path }

    it 'falls through to interactive wizard' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/triggers/)
      expect(Gum).to have_received(:choose).with('regular', 'regex', header: "Trigger type?\n")
    end
  end

  context 'empty trigger input (regular)' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regular')
      # First input empty, second valid
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return('', ':hello')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?'),
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hi')
      allow(Gum).to receive(:confirm).with('Add a label?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?', prompt_style: anything).and_return(false)

      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      stub_gum_preview
    end

    it 'warns the user that trigger cannot be empty' do
      allow(SnippetCli::UI).to receive(:warning)
      command.call
      expect(SnippetCli::UI).to have_received(:warning).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/':hello'|":hello"/)
    end
  end

  context 'empty trigger input (regex)' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: "Trigger type?\n").and_return('regex')
      # First input empty, second valid
      allow(Gum).to receive(:input).with(placeholder: 'r"^(hello|bye)$"').and_return('', '(gr|great)ing')
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hi')
      allow(Gum).to receive(:confirm).with('Add a label?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?', prompt_style: anything).and_return(false)

      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      stub_gum_preview
    end

    it 'warns the user that trigger cannot be empty' do
      allow(SnippetCli::UI).to receive(:warning)
      command.call
      expect(SnippetCli::UI).to have_received(:warning).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/regex:/)
    end
  end

  context 'empty replace input' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      # First input empty, second valid
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('', 'Hello world')
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'shows a transient warning that replacement cannot be empty' do
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      command.call
      expect(SnippetCli::UI).to have_received(:transient_warning).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('Hello world')
    end

    it 'clears the warning before re-prompting' do
      cleared = false
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> { cleared = true })
      command.call
      expect(cleared).to be true
    end
  end

  context 'empty multiline replace input' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      # First attempt: multiline with empty, second attempt: single-line with valid
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(true, false)
      allow(Gum).to receive(:write).with(header: 'Replacement', placeholder: 'Type expansion text...').and_return('')
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hello world')
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'shows a transient warning that replacement cannot be empty' do
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      command.call
      expect(SnippetCli::UI).to have_received(:transient_warning).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('Hello world')
    end
  end

  context 'empty alt type input (image_path)' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(true)
      allow(Gum).to receive(:filter)
        .with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
        .and_return('image_path')
      # First input empty, second valid
      allow(Gum).to receive(:input).with(placeholder: '/path/to/image.png')
                                   .and_return('', '/img/logo.png')
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'shows a transient warning that replacement cannot be empty' do
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      command.call
      expect(SnippetCli::UI).to have_received(:transient_warning).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('/img/logo.png')
    end

    it 'clears the warning before re-prompting' do
      cleared = false
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> { cleared = true })
      command.call
      expect(cleared).to be true
    end
  end

  context 'empty alt type input (html)' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(true)
      allow(Gum).to receive(:filter)
        .with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
        .and_return('html')
      # First input empty, second valid
      allow(Gum).to receive(:write)
        .with(header: 'Html', placeholder: 'Enter html...')
        .and_return('', '<b>Bold</b>')
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'shows a transient warning that replacement cannot be empty' do
      allow(SnippetCli::UI).to receive(:transient_warning).and_return(-> {})
      command.call
      expect(SnippetCli::UI).to have_received(:transient_warning).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('<b>Bold</b>')
    end
  end

  context 'mutually exclusive trigger flags' do
    it 'exits with non-zero status when --trigger and --triggers both provided' do
      expect do
        command.call(trigger: ':ty', triggers: ':ty,:thankyou', replace: 'x')
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/mutually exclusive/i).to_stderr
    end

    it 'exits with non-zero status when --trigger and --regex both provided' do
      expect do
        command.call(trigger: ':ty', regex: '\bty\b', replace: 'x')
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/mutually exclusive/i).to_stderr
    end

    it 'exits with non-zero status when all three trigger flags provided' do
      expect do
        command.call(trigger: ':ty', triggers: ':a,:b', regex: '\bty\b', replace: 'x')
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/mutually exclusive/i).to_stderr
    end
  end

  context '--trigger flag without --replace (partial wizard)' do
    before do
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Thank you')
      allow(Gum).to receive(:confirm).with('Add a label?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?', prompt_style: anything).and_return(false)

      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
    end

    it 'skips trigger prompts but enters wizard for vars/replace' do
      allow(Gum).to receive(:choose)
      captured = capture_display_input

      command.call(trigger: ':ty')

      expect(captured.join).to match(/trigger:/)
      expect(Gum).not_to have_received(:choose)
      expect(SnippetCli::VarBuilder).to have_received(:run)
    end
  end

  # ── alternative replacement types ──────────────────────────────────────────

  def stub_alt_type_prompts(type:)
    stub_trigger_prompts
    stub_alt_gate(type)
    yield if block_given?
    stub_post_replace_prompts
    stub_gum_preview
  end

  def stub_alt_gate(type)
    allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
    allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                         prompt_style: anything).and_return(true)
    allow(Gum).to receive(:filter)
      .with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
      .and_return(type)
  end

  context 'alternative replacement type: image_path' do
    before do
      stub_alt_type_prompts(type: 'image_path') do
        allow(Gum).to receive(:input).with(placeholder: '/path/to/image.png').and_return('/img/logo.png')
      end
    end

    it 'emits image_path: key in the YAML' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('image_path:')
    end

    it 'includes the entered path value' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('/img/logo.png')
    end

    it 'does not emit a replace: key' do
      captured = capture_display_input
      command.call
      expect(captured.join).not_to include('replace:')
    end
  end

  context 'alternative replacement type: html' do
    before do
      stub_alt_type_prompts(type: 'html') do
        allow(Gum).to receive(:write)
          .with(header: 'Html', placeholder: 'Enter html...')
          .and_return('<b>Bold</b>')
      end
    end

    it 'emits html: key in the YAML' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('html:')
    end

    it 'does not emit a replace: key' do
      captured = capture_display_input
      command.call
      expect(captured.join).not_to include('replace:')
    end
  end

  context 'alternative replacement type: markdown' do
    before do
      stub_alt_type_prompts(type: 'markdown') do
        allow(Gum).to receive(:write)
          .with(header: 'Markdown', placeholder: 'Enter markdown...')
          .and_return('**Bold**')
      end
    end

    it 'emits markdown: key in the YAML' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('markdown:')
    end

    it 'does not emit a replace: key' do
      captured = capture_display_input
      command.call
      expect(captured.join).not_to include('replace:')
    end
  end

  # ── var usage warnings ────────────────────────────────────────────────────

  let(:echo_var) { { name: 'myvar', type: 'echo', params: { echo: 'hi' } } }

  context 'var usage warning: unused var, user confirms yes to proceed' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([echo_var])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('plain text')
      allow(SnippetCli::UI).to receive(:warning)
      allow(Gum).to receive(:confirm).with('Are you sure you want to continue?',
                                           prompt_style: anything).and_return(true)
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'displays a warning mentioning the unused var' do
      command.call
      expect(SnippetCli::UI).to have_received(:warning).with(/myvar/)
    end

    it 'still outputs the snippet' do
      captured = capture_display_input
      command.call
      expect(captured.join).to match(/triggers/)
    end
  end

  context 'var usage warning: undeclared ref, user confirms yes to proceed' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hello {{ghost}}')
      allow(SnippetCli::UI).to receive(:warning)
      allow(Gum).to receive(:confirm).with('Are you sure you want to continue?',
                                           prompt_style: anything).and_return(true)
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'displays a warning mentioning the undeclared var' do
      command.call
      expect(SnippetCli::UI).to have_received(:warning).with(/ghost/)
    end
  end

  context 'var usage warning: user says no and re-enters replacement text' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([echo_var])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      # First: doesn't use {{myvar}}. Second: uses it — no warning → proceeds.
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('plain text', '{{myvar}} is great')
      allow(SnippetCli::UI).to receive(:warning)
      allow(Gum).to receive(:confirm).with('Are you sure you want to continue?',
                                           prompt_style: anything).and_return(false)
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'prompts for replacement text twice' do
      command.call
      expect(Gum).to have_received(:input).with(placeholder: 'Replacement text').twice
    end

    it 'uses the second (corrected) replacement in the output' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('myvar')
    end
  end

  context 'var usage warning with image_path: user says no and re-enters path' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(true)
      allow(Gum).to receive(:filter)
        .with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
        .and_return('image_path')
      # First path: undeclared ref → warning. Second path: plain path → no warnings.
      allow(Gum).to receive(:input).with(placeholder: '/path/to/image.png')
                                   .and_return('/imgs/{{ghost}}.png', '/imgs/logo.png')
      allow(SnippetCli::UI).to receive(:warning)
      allow(Gum).to receive(:confirm).with('Are you sure you want to continue?',
                                           prompt_style: anything).and_return(false)
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 're-prompts for the image path without re-asking the type gate' do
      command.call
      expect(Gum).to have_received(:input).with(placeholder: '/path/to/image.png').twice
      expect(Gum).to have_received(:filter).once
    end
  end

  # ── image_path + vars discard gate (TASK-33) ─────────────────────────────

  context 'image_path selected with vars defined: user confirms discard' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([echo_var])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(true)
      allow(Gum).to receive(:filter)
        .with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
        .and_return('image_path')
      allow(SnippetCli::UI).to receive(:info)
      allow(Gum).to receive(:confirm).with('Discard vars and continue with image_path?',
                                           prompt_style: anything).and_return(true)
      allow(Gum).to receive(:input).with(placeholder: '/path/to/image.png').and_return('/img/logo.png')
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'shows the discard warning via UI.info' do
      command.call
      expect(SnippetCli::UI).to have_received(:info)
        .with('image_path replacements do not support vars — they will be discarded.')
    end

    it 'emits image_path: key in the YAML' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('image_path:')
    end

    it 'does not emit vars: key in the YAML' do
      captured = capture_display_input
      command.call
      expect(captured.join).not_to include('vars:')
    end
  end

  context 'image_path selected with vars defined: user declines, then picks markdown' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([echo_var])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(true)
      allow(Gum).to receive(:filter)
        .with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
        .and_return('image_path', 'markdown')
      allow(SnippetCli::UI).to receive(:info)
      allow(Gum).to receive(:confirm).with('Discard vars and continue with image_path?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:write)
        .with(header: 'Markdown', placeholder: 'Enter markdown...')
        .and_return('**bold**')
      allow(SnippetCli::UI).to receive(:warning)
      allow(Gum).to receive(:confirm).with('Are you sure you want to continue?',
                                           prompt_style: anything).and_return(true)
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'prompts for replacement type twice' do
      command.call
      expect(Gum).to have_received(:filter)
        .with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
        .twice
    end

    it 'emits markdown: key in the final YAML' do
      captured = capture_display_input
      command.call
      expect(captured.join).to include('markdown:')
    end
  end

  context 'image_path selected with no vars: no discard gate shown' do
    before do
      stub_alt_type_prompts(type: 'image_path') do
        allow(Gum).to receive(:input).with(placeholder: '/path/to/image.png').and_return('/img/logo.png')
      end
      allow(SnippetCli::UI).to receive(:info)
    end

    it 'does not show the discard confirmation' do
      command.call
      expect(Gum).not_to have_received(:confirm).with('Discard vars and continue with image_path?',
                                                      prompt_style: anything)
    end
  end

  context 'var summary cleared before YAML output' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([echo_var])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hello {{myvar}}')
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'invokes VarBuilder.summary_clear before rendering the final YAML' do
      order = []
      allow(SnippetCli::VarBuilder).to receive(:summary_clear).and_return(-> { order << :cleared })
      allow(Gum::Command).to receive(:run_display_only) do |*|
        order << :yaml
        true
      end
      command.call
      expect(order).to eq(%i[cleared yaml])
    end
  end

  context 'no var usage warnings when replacement and vars match' do
    before do
      stub_trigger_prompts
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([echo_var])
      allow(Gum).to receive(:confirm).with('Alternative (non-plaintext) replacement type?',
                                           prompt_style: anything).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hello {{myvar}}')
      stub_post_replace_prompts
      stub_gum_preview
    end

    it 'does not show the continue confirmation' do
      allow(Gum).to receive(:confirm).with('Are you sure you want to continue?', prompt_style: anything)
      command.call
      expect(Gum).not_to have_received(:confirm).with('Are you sure you want to continue?', prompt_style: anything)
    end
  end

  context 'pipe output (SnippetCli.pipe_output set)' do
    let(:pipe_io) { StringIO.new }

    before do
      stub_happy_path
      SnippetCli.pipe_output = pipe_io
    end

    after { SnippetCli.pipe_output = nil }

    it 'writes raw YAML to pipe_output' do
      command.call
      expect(pipe_io.string).to match(/triggers/)
    end

    it 'does not call UI.info with "Snippet YAML below."' do
      allow(SnippetCli::UI).to receive(:info)
      command.call
      expect(SnippetCli::UI).not_to have_received(:info).with('Snippet YAML below.')
    end

    it 'does not call format_code' do
      allow(Gum::Command).to receive(:run_display_only)
      command.call
      expect(Gum::Command).not_to have_received(:run_display_only)
        .with('format', '--type=code', '--language=yaml', input: anything)
    end

    it 'writes valid YAML to pipe_output' do
      command.call
      expect { YAML.safe_load(pipe_io.string) }.not_to raise_error
    end
  end

  def capture_stdout
    old = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old
  end
end
