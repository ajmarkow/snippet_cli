# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/global_vars_writer'
require 'tmpdir'

RSpec.describe SnippetCli::GlobalVarsWriter do
  # Entries are pre-indented by 2 (matching vars_yaml output after stripping "vars:\n")
  let(:var_entries) { "  - name: dt\n    type: date\n    params:\n      format: \"%Y-%m-%d\"\n" }

  around do |example|
    Dir.mktmpdir do |dir|
      @tmpdir = dir
      example.run
    end
  end

  describe '.append' do
    context 'when file does not exist' do
      it 'creates the file with global_vars key and entries' do
        file = File.join(@tmpdir, 'new.yml')

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content).to start_with("global_vars:\n")
        expect(content).to include('- name: dt')
      end

      it 'produces valid YAML' do
        file = File.join(@tmpdir, 'new.yml')

        described_class.append(file, var_entries)

        content = File.read(file)
        expect { YAML.safe_load(content) }.not_to raise_error
      end
    end

    context 'when file is empty' do
      it 'writes global_vars key and entries' do
        file = File.join(@tmpdir, 'empty.yml')
        File.write(file, '')

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content).to start_with("global_vars:\n")
        expect(content).to include('- name: dt')
      end
    end

    context 'when file has matches but no global_vars' do
      it 'appends global_vars key and entries' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, "matches:\n  - trigger: \":hello\"\n    replace: \"Hello!\"\n")

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content).to include("global_vars:\n")
        expect(content).to include('- name: dt')
      end

      it 'preserves existing matches' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, "matches:\n  - trigger: \":hello\"\n    replace: \"Hello!\"\n")

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content).to include('trigger: ":hello"')
      end

      it 'produces valid YAML' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, "matches:\n  - trigger: \":hello\"\n    replace: \"Hello!\"\n")

        described_class.append(file, var_entries)

        content = File.read(file)
        expect { YAML.safe_load(content) }.not_to raise_error
      end
    end

    context 'when file already has global_vars' do
      let(:existing_content) { "global_vars:\n  - name: existing\n    type: echo\n    params:\n      echo: hi\n" }

      it 'appends new entries without overwriting existing ones' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, existing_content)

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content).to include('name: existing')
        expect(content).to include('name: dt')
      end

      it 'does not duplicate the global_vars key' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, existing_content)

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content.scan(/^global_vars:/).length).to eq(1)
      end

      it 'produces valid YAML' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, existing_content)

        described_class.append(file, var_entries)

        content = File.read(file)
        expect { YAML.safe_load(content) }.not_to raise_error
      end
    end

    context 'when file has global_vars followed by matches' do
      let(:existing_content) do
        "global_vars:\n  - name: existing\n    type: echo\n    params:\n      echo: hi\n\n" \
          "matches:\n  - trigger: \":hello\"\n    replace: \"Hello!\"\n"
      end

      it 'inserts new vars into global_vars block before matches' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, existing_content)

        described_class.append(file, var_entries)

        content = File.read(file)
        new_var_pos = content.index('name: dt')
        matches_pos = content.index('matches:')
        expect(new_var_pos).to be < matches_pos
      end

      it 'preserves matches' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, existing_content)

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content).to include('trigger: ":hello"')
      end

      it 'produces valid YAML' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, existing_content)

        described_class.append(file, var_entries)

        content = File.read(file)
        expect { YAML.safe_load(content) }.not_to raise_error
      end
    end

    context 'with multiple var entries' do
      let(:var_entries) do
        "  - name: dt\n    type: date\n    params:\n      format: \"%Y-%m-%d\"\n  " \
          "- name: clipboard\n    type: clipboard\n"
      end

      it 'appends all entries' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, '')

        described_class.append(file, var_entries)

        content = File.read(file)
        expect(content).to include('name: dt')
        expect(content).to include('name: clipboard')
      end
    end

    it 'indents entries by 2 spaces under global_vars' do
      file = File.join(@tmpdir, 'base.yml')
      File.write(file, '')

      described_class.append(file, var_entries)

      content = File.read(file)
      expect(content).to include('  - name: dt')
      expect(content).to include('    type: date')
    end
  end

  describe '.read_names' do
    it 'returns var names from global_vars key' do
      file = File.join(@tmpdir, 'base.yml')
      File.write(file, "global_vars:\n  - name: dt\n    type: date\n  - name: clip\n    type: clipboard\n")

      expect(described_class.read_names(file)).to eq(%w[dt clip])
    end

    it 'returns empty array when file has no global_vars' do
      file = File.join(@tmpdir, 'base.yml')
      File.write(file, "matches:\n  - trigger: \":hi\"\n    replace: \"hi\"\n")

      expect(described_class.read_names(file)).to eq([])
    end

    it 'returns empty array when file does not exist' do
      file = File.join(@tmpdir, 'missing.yml')

      expect(described_class.read_names(file)).to eq([])
    end

    it 'returns empty array when global_vars is empty' do
      file = File.join(@tmpdir, 'base.yml')
      File.write(file, "global_vars: []\n")

      expect(described_class.read_names(file)).to eq([])
    end

    it 'handles YAML files containing symbol values without raising Psych::DisallowedClass' do
      file = File.join(@tmpdir, 'base.yml')
      # Espanso match files may contain bare symbol-like values (e.g. :trigger)
      # that Ruby 4.0's YAML.safe_load rejects unless Symbol is permitted
      File.write(file, "matches:\n  - trigger: \":hello\"\n    word: true\n    replace: \"Hello!\"\n")

      expect { described_class.read_names(file) }.not_to raise_error
    end
  end
end
