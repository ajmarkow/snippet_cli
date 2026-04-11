# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/commands/check'
require 'snippet_cli/espanso_config'

RSpec.describe SnippetCli::Commands::Check do
  subject(:command) { described_class.new }

  let(:valid_fixture)   { File.join(__dir__, '..', 'fixtures', 'valid_matchfile.yml') }
  let(:invalid_fixture) { File.join(__dir__, '..', 'fixtures', 'invalid_matchfile.yml') }

  context 'when --file is not provided' do
    context 'when no match files exist' do
      before { allow(SnippetCli::EspansoConfig).to receive(:match_files).and_return([]) }

      it 'shows a UI.error and exits 1' do
        allow(SnippetCli::UI).to receive(:error)
        expect { command.call }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        expect(SnippetCli::UI).to have_received(:error).with(/no match files/i)
      end
    end

    context 'when exactly one match file exists' do
      before do
        allow(SnippetCli::EspansoConfig).to receive(:match_files).and_return([valid_fixture])
        allow(Gum).to receive(:filter)
        allow(SnippetCli::UI).to receive(:success)
      end

      it 'auto-selects the file and checks it without prompting' do
        expect { command.call }.not_to raise_error
        expect(SnippetCli::UI).to have_received(:success).with(/valid/i)
      end

      it 'does not prompt via Gum.filter' do
        command.call
        expect(Gum).not_to have_received(:filter)
      end
    end

    context 'when multiple match files exist' do
      let(:another_fixture) { File.join(__dir__, '..', 'fixtures', 'valid_matchfile_full.yml') }

      before do
        allow(SnippetCli::EspansoConfig).to receive(:match_files).and_return([valid_fixture, another_fixture])
        allow(Gum).to receive(:filter).and_return(File.basename(valid_fixture))
        allow(SnippetCli::UI).to receive(:success)
      end

      it 'prompts the user to pick a file via Gum.filter' do
        command.call
        expect(Gum).to have_received(:filter)
      end

      it 'checks the chosen file' do
        expect { command.call }.not_to raise_error
        expect(SnippetCli::UI).to have_received(:success).with(/valid/i)
      end
    end
  end

  context 'when file does not exist' do
    it 'writes an error to stderr and exits 1' do
      expect do
        command.call(file: 'nonexistent.yml')
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/not found/i).to_stderr
    end
  end

  context 'when file contains invalid YAML' do
    let(:bad_file) do
      Tempfile.new(['bad', '.yml']).tap do |f|
        f.write("foo: [\nbad yaml")
        f.close
      end
    end
    after { bad_file.unlink }

    it 'writes an error to stderr and exits 1' do
      expect do
        command.call(file: bad_file.path)
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/invalid yaml/i).to_stderr
    end
  end

  context 'with a valid matchfile' do
    before { allow(SnippetCli::UI).to receive(:success) }

    it 'renders a success box via UI.success' do
      command.call(file: valid_fixture)
      expect(SnippetCli::UI).to have_received(:success).with(/valid/i)
    end

    it 'does not exit with non-zero status' do
      expect { command.call(file: valid_fixture) }.not_to raise_error
    end
  end

  # AC #4: checks at matchfile scope (matches array), not per-item scope.
  # A bare match object missing the top-level `matches` key must fail,
  # proving the checker understands full-file structure rather than
  # individual match entries.
  context 'full matchfile scope (not per-item)' do
    let(:bare_match_file) do
      Tempfile.new(['bare', '.yml']).tap do |f|
        f.write("trigger: \":hello\"\nreplace: \"Hello!\"\n")
        f.close
      end
    end
    after { bare_match_file.unlink }

    it 'rejects a bare match object that lacks the top-level matches key' do
      expect do
        command.call(file: bare_match_file.path)
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/matches/i).to_stderr
    end

    it 'accepts a proper matchfile with a top-level matches array' do
      allow(SnippetCli::UI).to receive(:success)
      expect { command.call(file: valid_fixture) }.not_to raise_error
    end
  end

  context 'with an invalid matchfile' do
    it 'exits with status 1' do
      expect do
        command.call(file: invalid_fixture)
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'prints validation errors to stderr' do
      expect do
        command.call(file: invalid_fixture)
      end.to raise_error(SystemExit)
        .and output(/error/i).to_stderr
    end

    it 'includes field-level detail in the error output' do
      expect do
        command.call(file: invalid_fixture)
      end.to raise_error(SystemExit)
        .and output(/matches/).to_stderr
    end
  end
end
