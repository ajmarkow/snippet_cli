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
    allow(SnippetCli::VarBuilder).to receive(:run).with(skip_initial_prompt: true).and_return(vars)
  end

  it 'calls VarBuilder.run with skip_initial_prompt: true' do
    expect(SnippetCli::VarBuilder).to receive(:run).with(skip_initial_prompt: true).and_return(vars)
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

  context 'pipe output (stdout not a TTY)' do
    before { allow($stdout).to receive(:tty?).and_return(false) }

    it 'writes raw vars YAML to stdout' do
      expect { command.call }.to output(/vars:/).to_stdout
    end

    it 'does not call format_code' do
      allow(Gum::Command).to receive(:run_display_only)
      command.call
      expect(Gum::Command).not_to have_received(:run_display_only)
        .with('format', '--type=code', '--language=yaml', input: anything)
    end
  end

  context 'when no vars are added' do
    before { allow(SnippetCli::VarBuilder).to receive(:run).and_return([]) }

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
