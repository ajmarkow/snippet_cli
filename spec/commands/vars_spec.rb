# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/commands/vars'

RSpec.describe SnippetCli::Commands::Vars do
  subject(:command) { described_class.new }

  let(:vars) do
    [{ name: 'dt', type: 'date', params: { format: '%Y-%m-%d' } }]
  end

  before do
    allow($stdout).to receive(:tty?).and_return(true)
    allow(SnippetCli::VarBuilder).to receive(:run)
      .with(skip_initial_prompt: true)
      .and_return({ vars: vars, summary_clear: -> {} })
  end

  it 'calls VarBuilder.run with skip_initial_prompt: true' do
    expect(SnippetCli::VarBuilder).to receive(:run)
      .with(skip_initial_prompt: true)
      .and_return({ vars: vars, summary_clear: -> {} })
    command.call
  end

  context 'TTY output mode' do
    let(:captured_display_input) { [] }

    before do
      allow(Gum::Command).to receive(:run_display_only) do |*, input: nil, **|
        captured_display_input << input
        true
      end
    end

    it 'syntax-highlights the YAML output via Gum::Command.run_display_only' do
      command.call
      expect(Gum::Command).to have_received(:run_display_only)
        .with('format', '--type=code', '--language=yaml', input: anything)
    end

    it 'passes the vars YAML block for display' do
      command.call
      expect(captured_display_input.join).to match(/vars:/)
    end

    it 'includes the var name' do
      command.call
      expect(captured_display_input.join).to match(/name: dt/)
    end

    it 'includes the var type' do
      command.call
      expect(captured_display_input.join).to match(/type: date/)
    end
  end

  context 'pipe output (SnippetCli.pipe_output set)' do
    let(:pipe_io) { StringIO.new }

    before { allow(SnippetCli).to receive(:pipe_output).and_return(pipe_io) }

    it 'writes raw vars YAML to pipe_output' do
      command.call
      expect(pipe_io.string).to match(/vars:/)
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

  context 'when no vars are added' do
    before { allow(SnippetCli::VarBuilder).to receive(:run).and_return({ vars: [], summary_clear: -> {} }) }

    it 'passes an empty vars block for display' do
      captured = []
      allow(Gum::Command).to receive(:run_display_only) do |*, input: nil, **|
        captured << input
        true
      end
      command.call
      expect(captured.join).to match(/vars/)
    end
  end

  # ── --save flag ──────────────────────────────────────────────────────────────

  context '--save flag' do
    let(:match_dir) { '/home/user/.config/espanso/match' }
    let(:match_files) do
      ["#{match_dir}/base.yml", "#{match_dir}/code.yml"]
    end

    before do
      allow(SnippetCli::EspansoConfig).to receive(:match_dir).and_return(match_dir)
      allow(SnippetCli::EspansoConfig).to receive(:match_files).and_return(match_files)
      allow(Gum).to receive(:filter).with(
        *match_files.map { |f| File.basename(f) },
        header: 'Save to which match file?'
      ).and_return('base.yml')
      allow(SnippetCli::GlobalVarsWriter).to receive(:append)
      allow(SnippetCli::UI).to receive(:success)
    end

    it 'prompts the user to pick a match file via Gum.filter' do
      command.call(save: true)

      expect(Gum).to have_received(:filter).with(
        *match_files.map { |f| File.basename(f) },
        header: 'Save to which match file?'
      )
    end

    it 'appends vars to the chosen file via GlobalVarsWriter' do
      command.call(save: true)

      expect(SnippetCli::GlobalVarsWriter).to have_received(:append).with(
        "#{match_dir}/base.yml", anything
      )
    end

    it 'passes pre-indented var entries to GlobalVarsWriter' do
      command.call(save: true)

      expect(SnippetCli::GlobalVarsWriter).to have_received(:append) do |_path, entries|
        expect(entries).to include('  - name: dt')
        expect(entries).to include('    type: date')
      end
    end

    it 'shows a success message with the filename' do
      command.call(save: true)

      expect(SnippetCli::UI).to have_received(:success).with(/base\.yml/)
    end

    it 'still outputs the vars YAML normally' do
      captured = []
      allow(Gum::Command).to receive(:run_display_only) do |*, input: nil, **|
        captured << input
        true
      end
      command.call(save: true)

      expect(captured.join).to match(/vars:/)
    end

    context 'when no vars are added' do
      before do
        allow(SnippetCli::VarBuilder).to receive(:run)
          .and_return({ vars: [], summary_clear: -> {} })
      end

      it 'does not prompt for a file' do
        command.call(save: true)

        expect(Gum).not_to have_received(:filter)
      end

      it 'does not call GlobalVarsWriter' do
        command.call(save: true)

        expect(SnippetCli::GlobalVarsWriter).not_to have_received(:append)
      end
    end

    context 'when only one match file exists' do
      let(:match_files) { ["#{match_dir}/base.yml"] }

      before do
        allow(Gum).to receive(:filter)
      end

      it 'skips Gum.filter and auto-selects the file' do
        command.call(save: true)

        expect(Gum).not_to have_received(:filter)
      end

      it 'saves to the single file' do
        command.call(save: true)

        expect(SnippetCli::GlobalVarsWriter).to have_received(:append).with(
          "#{match_dir}/base.yml", anything
        )
      end

      it 'shows a success message with the filename' do
        command.call(save: true)

        expect(SnippetCli::UI).to have_received(:success).with(/base\.yml/)
      end
    end

    context 'when user cancels file picker (Ctrl+C)' do
      before do
        allow(Gum).to receive(:filter).and_return(nil)
      end

      it 'exits with interrupted message' do
        expect { command.call(save: true) }
          .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
      end
    end

    context 'when no match files found' do
      before do
        allow(SnippetCli::EspansoConfig).to receive(:match_files).and_return([])
      end

      it 'shows an error and exits' do
        allow(SnippetCli::UI).to receive(:error)
        expect { command.call(save: true) }.to raise_error(SystemExit)
        expect(SnippetCli::UI).to have_received(:error).with(/no match files/i)
      end
    end

    context 'when espanso config discovery fails' do
      before do
        allow(SnippetCli::EspansoConfig).to receive(:match_files)
          .and_raise(SnippetCli::EspansoConfigError, 'Could not determine Espanso config path.')
      end

      it 'shows an error and exits' do
        allow(SnippetCli::UI).to receive(:error)
        expect { command.call(save: true) }.to raise_error(SystemExit)
        expect(SnippetCli::UI).to have_received(:error).with(/could not determine/i)
      end
    end
  end

  context 'when VarBuilder is interrupted' do
    before do
      allow(SnippetCli::VarBuilder).to receive(:run).and_raise(SnippetCli::WizardInterrupted)
      allow(Gum::Command).to receive(:run_non_interactive).and_wrap_original do |_m, *_args, input: nil, **_opts|
        input.to_s
      end
    end

    it 'prints interrupted message and exits cleanly' do
      expect { command.call }
        .to output(/Interrupted.*exiting snippet_cli/im).to_stdout
    end
  end
end
