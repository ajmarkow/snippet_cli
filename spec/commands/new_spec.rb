# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/commands/new'

RSpec.describe SnippetCli::Commands::New do
  subject(:command) { described_class.new }

  let(:fixture_path) { File.join(__dir__, '..', 'fixtures', 'duplicate_triggers.yml') }

  # Shared Gum stubs for a minimal happy-path run.
  # Split into focused helpers so each stays under the method-length threshold.
  def stub_happy_path(trigger_type: 'regular', trigger: ':test', replace: 'Test replacement')
    stub_trigger_prompts(trigger_type: trigger_type, trigger: trigger)
    stub_replace_prompts(replace: replace)
    stub_gum_preview
    allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
  end

  def stub_trigger_prompts(trigger_type: 'regular', trigger: ':test')
    allow(Gum).to receive(:choose)
      .with('regular', 'regex', header: 'Trigger type?').and_return(trigger_type)
    allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(trigger)
    allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')).and_return(false)
  end

  def stub_replace_prompts(replace: 'Test replacement')
    allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
    allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return(replace)
    stub_post_replace_prompts
  end

  def stub_post_replace_prompts
    allow(Gum).to receive(:confirm).with('Add a label?').and_return(false)
    allow(Gum).to receive(:confirm).with('Add a comment?').and_return(false)
    allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(false)
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
      command.call(no_clipboard: true)
      expect(SnippetCli::UI).to have_received(:info).with('Snippet YAML below.')
    end

    it 'syntax-highlights the YAML output via Gum::Command.run_display_only' do
      allow(Gum::Command).to receive(:run_display_only).and_return(true)
      command.call(no_clipboard: true)
      expect(Gum::Command).to have_received(:run_display_only)
        .with('format', '--type=code', '--language=yaml', input: anything)
    end

    it 'passes YAML containing triggers to display' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/triggers/)
    end

    it 'passes the entered trigger value to display' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/':test'|":test"/)
    end

    it 'passes the replacement text to display' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/Test replacement/)
    end
  end

  context 'regex trigger type' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regex')
      allow(Gum).to receive(:input).with(placeholder: 'r"^(hello|bye)$"').and_return('(gr|great)ing')
      allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hello')
      allow(Gum).to receive(:confirm).with('Add a label?').and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?').and_return(false)
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(false)
      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
    end

    it 'passes YAML with regex: key to display' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/regex:/)
    end

    it 'does not include triggers: key in the YAML' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).not_to include('triggers:')
    end
  end

  context 'with label and comment' do
    before do
      stub_happy_path
      allow(Gum).to receive(:confirm).with('Add a label?').and_return(true)
      allow(Gum).to receive(:input).with(placeholder: 'Label').and_return('My label')
      allow(Gum).to receive(:confirm).with('Add a comment?').and_return(true)
      allow(Gum).to receive(:input).with(placeholder: 'Comment').and_return('My comment')
    end

    it 'includes the label' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/label:/)
    end

    it 'includes the comment' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/comment:/)
    end
  end

  context 'schema validation failure' do
    before do
      stub_happy_path
      allow(SnippetCli::SnippetBuilder).to receive(:build)
        .and_raise(SnippetCli::ValidationError, "Schema validation failed:\n  - bad field")
    end

    it 'renders the error message via UI.info' do
      allow(SnippetCli::UI).to receive(:info)
      expect { command.call(no_clipboard: true) }.to raise_error(SystemExit)
      expect(SnippetCli::UI).to have_received(:info).with(/Schema validation failed/)
    end

    it 'exits with status 1' do
      allow(SnippetCli::UI).to receive(:info)
      expect { command.call(no_clipboard: true) }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  context 'conflict detection with --file' do
    before do
      stub_happy_path(trigger: ':hello') # :hello exists in fixture
    end

    it 'warns about the conflicting trigger and exits 1' do
      expect do
        command.call(file: fixture_path, no_clipboard: true)
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
        command.call(file: fixture_path, no_warn: true, no_clipboard: true)
      end.not_to raise_error
    end
  end

  context 'confirmed snippet with clipboard' do
    before do
      stub_happy_path
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(true)
      stub_const('Clipboard', Module.new { def self.copy(_); end })
    end

    it 'renders "Copied to clipboard" via UI.success' do
      allow(SnippetCli::UI).to receive(:success)
      command.call(no_clipboard: false)
      expect(SnippetCli::UI).to have_received(:success).with('Copied to clipboard.')
    end

    it 'copies to clipboard and prints confirmation' do
      expect { command.call(no_clipboard: false) }
        .to output(/copied to clipboard/i).to_stdout
    end

    it 'does not render a bordered box around the snippet' do
      received_args = []
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, input: nil, **|
        received_args.concat(args)
        input.to_s
      end
      command.call(no_clipboard: false)
      expect(received_args.join(' ')).not_to include('--border=double')
    end

    it 'syntax-highlights the YAML output via Gum::Command.run_display_only' do
      allow(Gum::Command).to receive(:run_display_only).and_return(true)
      command.call(no_clipboard: false)
      expect(Gum::Command).to have_received(:run_display_only)
        .with('format', '--type=code', '--language=yaml', input: anything)
    end
  end

  context 'declined copy to clipboard' do
    before do
      stub_happy_path
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(false)
    end

    it 'renders "Not copied to clipboard" via UI.info' do
      allow(SnippetCli::UI).to receive(:info)
      command.call(no_clipboard: false)
      expect(SnippetCli::UI).to have_received(:info).with('Not copied to clipboard.')
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

      expect { command.call(no_clipboard: true) }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
    end

    it 'does not call any further Gum prompts after Gum.choose returns nil' do
      allow(Gum).to receive(:choose).and_return(nil)
      allow(Gum).to receive(:input)
      allow(Gum).to receive(:confirm)

      expect { command.call(no_clipboard: true) }.to output(anything).to_stdout
      expect(Gum).not_to have_received(:input)
      expect(Gum).not_to have_received(:confirm)
    end

    it 'exits immediately with interrupted message when Gum.input returns nil mid-wizard (Ctrl+C at trigger input)' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(nil)
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')).and_return(false)

      expect { command.call(no_clipboard: true) }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
    end

    it 'exits immediately with interrupted message when Gum.input returns nil at replace prompt' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')).and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return(nil)

      expect { command.call(no_clipboard: true) }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
    end

    it 'does not call SnippetBuilder when interrupted at replace prompt' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')).and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return(nil)
      allow(SnippetCli::SnippetBuilder).to receive(:build)

      expect { command.call(no_clipboard: true) }.to output(anything).to_stdout
      expect(SnippetCli::SnippetBuilder).not_to have_received(:build)
    end

    it 'exits immediately when Ctrl+C on Gum.confirm (exit code 130) at "Add another trigger?"' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')) do
        # Simulate system() setting $? to exit 130 (Ctrl+C)
        system('exit 130')
        false
      end
      allow(SnippetCli::VarBuilder).to receive(:run)

      expect { command.call(no_clipboard: true) }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
      expect(SnippetCli::VarBuilder).not_to have_received(:run)
    end

    it 'exits immediately when Ctrl+C on Gum.confirm (exit code 130) at "Multi-line replacement?"' do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':test')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')).and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      allow(Gum).to receive(:confirm).with('Multi-line replacement?') do
        system('exit 130')
        false
      end
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text')

      expect { command.call(no_clipboard: true) }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
      expect(Gum).not_to have_received(:input).with(placeholder: 'Replacement text')
    end
  end

  context 'confirmed snippet with --no-clipboard' do
    before do
      stub_happy_path
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(true)
    end

    it 'does not raise' do
      expect { command.call(no_clipboard: true) }.not_to raise_error
    end
  end

  context 'multiple regular triggers' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regular')
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return(':hello', ':hi')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')).and_return(true, false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hey!')
      allow(Gum).to receive(:confirm).with('Add a label?').and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?').and_return(false)
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(false)
      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
    end

    it 'includes both triggers' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/':hello'|":hello"/)
    end
  end

  # ── CLI trigger flags (TASK-3) ──────────────────────────────────────────────

  context '--trigger flag with --replace (skip wizard entirely)' do
    it 'emits YAML with singular trigger: key' do
      captured = capture_display_input
      command.call(trigger: ':ty', replace: 'Thank you', no_clipboard: true)
      expect(captured.join).to match(/trigger: ":ty"/)
    end

    it 'does not emit triggers: array key' do
      captured = capture_display_input
      command.call(trigger: ':ty', replace: 'Thank you', no_clipboard: true)
      expect(captured.join).not_to include('triggers:')
    end

    it 'does not invoke any Gum prompts' do
      allow(Gum).to receive(:choose)
      allow(Gum).to receive(:input)
      allow(Gum).to receive(:confirm)

      command.call(trigger: ':ty', replace: 'Thank you', no_clipboard: true)

      expect(Gum).not_to have_received(:choose)
      expect(Gum).not_to have_received(:input)
      expect(Gum).not_to have_received(:confirm)
    end
  end

  context '--triggers flag with --replace' do
    it 'emits YAML with triggers: array containing both values' do
      captured = capture_display_input
      command.call(triggers: ':ty,:thankyou', replace: 'Thank you', no_clipboard: true)
      expect(captured.join).to include('triggers:')
      expect(captured.join).to match(/':ty'|":ty"/)
      expect(captured.join).to match(/':thankyou'|":thankyou"/)
    end
  end

  context '--regex flag with --replace' do
    it 'emits YAML with regex: key' do
      captured = capture_display_input
      command.call(regex: '\bty\b', replace: 'Thank you', no_clipboard: true)
      expect(captured.join).to include('regex:')
      expect(captured.join).not_to include('triggers:')
      expect(captured.join).not_to include('trigger:')
    end
  end

  context 'no trigger flags provided' do
    before { stub_happy_path }

    it 'falls through to interactive wizard' do
      captured = capture_display_input
      command.call(no_clipboard: true)
      expect(captured.join).to match(/triggers/)
      expect(Gum).to have_received(:choose).with('regular', 'regex', header: 'Trigger type?')
    end
  end

  context 'empty trigger input (regular)' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regular')
      # First input empty, second valid
      allow(Gum).to receive(:input).with(hash_including(placeholder: ':trigger')).and_return('', ':hello')
      allow(Gum).to receive(:confirm).with(a_string_including('Add another trigger?')).and_return(false)
      allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hi')
      allow(Gum).to receive(:confirm).with('Add a label?').and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?').and_return(false)
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      stub_gum_preview
    end

    it 'warns the user that trigger cannot be empty' do
      allow(SnippetCli::UI).to receive(:info)
      command.call(no_clipboard: false)
      expect(SnippetCli::UI).to have_received(:info).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call(no_clipboard: false)
      expect(captured.join).to match(/':hello'|":hello"/)
    end
  end

  context 'empty trigger input (regex)' do
    before do
      allow(Gum).to receive(:choose).with('regular', 'regex', header: 'Trigger type?').and_return('regex')
      # First input empty, second valid
      allow(Gum).to receive(:input).with(placeholder: 'r"^(hello|bye)$"').and_return('', '(gr|great)ing')
      allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Hi')
      allow(Gum).to receive(:confirm).with('Add a label?').and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?').and_return(false)
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(false)
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
      stub_gum_preview
    end

    it 'warns the user that trigger cannot be empty' do
      allow(SnippetCli::UI).to receive(:info)
      command.call(no_clipboard: false)
      expect(SnippetCli::UI).to have_received(:info).with(/cannot be empty/i)
    end

    it 're-prompts and accepts the next non-empty input' do
      captured = capture_display_input
      command.call(no_clipboard: false)
      expect(captured.join).to match(/regex:/)
    end
  end

  context 'mutually exclusive trigger flags' do
    it 'exits with non-zero status when --trigger and --triggers both provided' do
      expect do
        command.call(trigger: ':ty', triggers: ':ty,:thankyou', replace: 'x', no_clipboard: true)
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/mutually exclusive/i).to_stderr
    end

    it 'exits with non-zero status when --trigger and --regex both provided' do
      expect do
        command.call(trigger: ':ty', regex: '\bty\b', replace: 'x', no_clipboard: true)
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/mutually exclusive/i).to_stderr
    end

    it 'exits with non-zero status when all three trigger flags provided' do
      expect do
        command.call(trigger: ':ty', triggers: ':a,:b', regex: '\bty\b', replace: 'x', no_clipboard: true)
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/mutually exclusive/i).to_stderr
    end
  end

  context '--trigger flag without --replace (partial wizard)' do
    before do
      allow(Gum).to receive(:confirm).with('Multi-line replacement?').and_return(false)
      allow(Gum).to receive(:input).with(placeholder: 'Replacement text').and_return('Thank you')
      allow(Gum).to receive(:confirm).with('Add a label?').and_return(false)
      allow(Gum).to receive(:confirm).with('Add a comment?').and_return(false)
      allow(Gum).to receive(:confirm).with('Copy to clipboard?').and_return(false)
      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
      allow(SnippetCli::VarBuilder).to receive(:run).and_return([])
    end

    it 'skips trigger prompts but enters wizard for vars/replace' do
      allow(Gum).to receive(:choose)
      captured = capture_display_input

      command.call(trigger: ':ty', no_clipboard: true)

      expect(captured.join).to match(/trigger:/)
      expect(Gum).not_to have_received(:choose)
      expect(SnippetCli::VarBuilder).to have_received(:run)
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
