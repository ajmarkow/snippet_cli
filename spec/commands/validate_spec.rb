# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/commands/validate'

RSpec.describe SnippetCli::Commands::Validate do
  subject(:command) { described_class.new }

  let(:valid_fixture)   { File.join(__dir__, '..', 'fixtures', 'valid_matchfile.yml') }
  let(:invalid_fixture) { File.join(__dir__, '..', 'fixtures', 'invalid_matchfile.yml') }

  context 'when --file is not provided' do
    it 'shows a UI.error and exits 1' do
      allow(SnippetCli::UI).to receive(:error)
      expect { command.call }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      expect(SnippetCli::UI).to have_received(:error).with(/--file.*required/i)
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

  # AC #4: validates at matchfile scope (matches array), not per-item scope.
  # A bare match object missing the top-level `matches` key must fail,
  # proving the validator understands full-file structure rather than
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
