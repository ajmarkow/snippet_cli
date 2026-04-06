# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/commands/conflict'

RSpec.describe SnippetCli::Commands::Conflict do
  subject(:command) { described_class.new }

  let(:fixture_path) { File.join(__dir__, '..', 'fixtures', 'duplicate_triggers.yml') }
  let(:clean_yaml) do
    <<~YAML
      matches:
        - trigger: ":hello"
          replace: "Hello!"
        - trigger: ":world"
          replace: "World!"
    YAML
  end
  let(:clean_file) do
    Tempfile.new(['clean', '.yml']).tap do |f|
      f.write(clean_yaml)
      f.close
    end
  end

  after { clean_file.unlink }

  context 'when --file is not provided' do
    it 'shows a UI.error and exits 1' do
      allow(SnippetCli::UI).to receive(:error)
      expect { command.call }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      expect(SnippetCli::UI).to have_received(:error).with(/--file.*required/i)
    end
  end

  context 'when file does not exist' do
    it 'shows a UI.error and exits 1' do
      allow(SnippetCli::UI).to receive(:error)
      expect { command.call(file: 'nonexistent.yml') }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      expect(SnippetCli::UI).to have_received(:error).with(/not found/i)
    end
  end

  context 'when file has invalid YAML' do
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

  context 'with no trigger argument (mode 1)' do
    context 'when file has no conflicts' do
      it 'prints "No conflicts found" and does not raise' do
        expect { command.call(file: clean_file.path) }
          .to output(/No conflicts found/i).to_stdout
      end
    end

    context 'when file has conflicts' do
      it 'calls Gum.table with conflict rows' do
        allow(Gum).to receive(:table)
        command.call(file: fixture_path)
        expect(Gum).to have_received(:table) do |rows, **|
          triggers = rows.map { |r| r[0] }
          expect(triggers).to include(':hello', ':bye')
        end
      end

      it 'passes Trigger, Lines columns to Gum.table' do
        allow(Gum).to receive(:table)
        command.call(file: fixture_path)
        expect(Gum).to have_received(:table).with(anything, columns: %w[Trigger Lines], separator: "\t", print: true)
      end

      it 'joins line numbers with commas for each trigger group' do
        allow(Gum).to receive(:table)
        command.call(file: fixture_path)
        expect(Gum).to have_received(:table) do |rows, **|
          hello_row = rows.find { |r| r[0] == ':hello' }
          expect(hello_row[1]).to include(',')
        end
      end

      it 'prints a header before the table' do
        allow(Gum).to receive(:table)
        expect { command.call(file: fixture_path) }
          .to output(/The following conflicts were found/).to_stdout
      end
    end
  end

  context 'with a trigger option (mode 2)' do
    context 'when the trigger exists in the file' do
      it 'calls Gum.table with rows matching that trigger' do
        allow(Gum).to receive(:table)
        command.call(file: fixture_path, trigger: [':hello'])
        expect(Gum).to have_received(:table) do |rows, **|
          expect(rows).not_to be_empty
          expect(rows.map { |r| r[0] }).to all(eq(':hello'))
        end
      end
    end

    context 'when the trigger is not in the file' do
      it 'prints "not found" message' do
        expect { command.call(file: clean_file.path, trigger: [':missing']) }
          .to output(/not found/i).to_stdout
      end
    end

    context 'with multiple triggers' do
      it 'shows rows for all specified triggers' do
        allow(Gum).to receive(:table)
        command.call(file: fixture_path, trigger: [':hello', ':bye'])
        expect(Gum).to have_received(:table) do |rows, **|
          expect(rows).not_to be_empty
          triggers_in_rows = rows.map { |r| r[0] }.uniq
          expect(triggers_in_rows).to include(':hello', ':bye')
        end
      end
    end
  end
end
