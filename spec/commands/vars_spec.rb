# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/commands/vars'

RSpec.describe SnippetCli::Commands::Vars do
  subject(:command) { described_class.new }

  let(:vars) do
    [{ name: 'dt', type: 'date', params: { format: '%Y-%m-%d' } }]
  end

  before do
    allow(SnippetCli::VarBuilder).to receive(:run).and_return(vars)
  end

  context 'with --no-clipboard (stdout mode)' do
    it 'prints the vars YAML block to stdout' do
      expect { command.call(no_clipboard: true) }
        .to output(/vars:/).to_stdout
    end

    it 'includes the var name' do
      expect { command.call(no_clipboard: true) }
        .to output(/name: dt/).to_stdout
    end

    it 'includes the var type' do
      expect { command.call(no_clipboard: true) }
        .to output(/type: date/).to_stdout
    end
  end

  context 'with clipboard mode (default)' do
    before do
      stub_const('Clipboard', Module.new { def self.copy(_); end })
    end

    it 'copies to clipboard and prints a confirmation' do
      expect { command.call(no_clipboard: false) }
        .to output(/copied to clipboard/i).to_stdout
    end

    it 'does not raise' do
      expect { command.call(no_clipboard: false) }.not_to raise_error
    end
  end

  context 'when no vars are added' do
    before { allow(SnippetCli::VarBuilder).to receive(:run).and_return([]) }

    it 'outputs an empty vars block in stdout mode' do
      expect { command.call(no_clipboard: true) }
        .to output(/vars/).to_stdout
    end
  end
end
