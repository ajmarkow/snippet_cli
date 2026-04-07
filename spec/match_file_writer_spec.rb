# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/match_file_writer'
require 'tmpdir'

RSpec.describe SnippetCli::MatchFileWriter do
  let(:snippet_yaml) do
    <<~YAML
      - trigger: ":test"
        replace: "hello world"
    YAML
  end

  around do |example|
    Dir.mktmpdir do |dir|
      @tmpdir = dir
      example.run
    end
  end

  describe '.append' do
    context 'when file exists with matches' do
      it 'appends the indented snippet to the file' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, "matches:\n  - trigger: \":hi\"\n    replace: \"hi\"\n")

        described_class.append(file, snippet_yaml)

        content = File.read(file)
        expect(content).to include('- trigger: ":test"')
        expect(content).to end_with("\n")
      end

      it 'preserves existing content' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, "matches:\n  - trigger: \":hi\"\n    replace: \"hi\"\n")

        described_class.append(file, snippet_yaml)

        content = File.read(file)
        expect(content).to include('trigger: ":hi"')
      end
    end

    context 'when file does not exist' do
      it 'creates the file with matches: prefix' do
        file = File.join(@tmpdir, 'new.yml')

        described_class.append(file, snippet_yaml)

        content = File.read(file)
        expect(content).to start_with("matches:\n")
        expect(content).to include('- trigger: ":test"')
      end
    end

    context 'when file is empty' do
      it 'writes matches: prefix before the snippet' do
        file = File.join(@tmpdir, 'empty.yml')
        File.write(file, '')

        described_class.append(file, snippet_yaml)

        content = File.read(file)
        expect(content).to start_with("matches:\n")
      end
    end

    it 'indents the snippet by 2 spaces' do
      file = File.join(@tmpdir, 'base.yml')
      File.write(file, "matches:\n")

      described_class.append(file, snippet_yaml)

      content = File.read(file)
      # The `- trigger:` line should be indented by 2 spaces
      expect(content).to include('  - trigger:')
      expect(content).to include('    replace:')
    end

    context 'when existing file has no trailing newline' do
      it 'ensures new snippet starts on its own line' do
        file = File.join(@tmpdir, 'no_newline.yml')
        File.write(file, "matches:\n  - trigger: \":hi\"\n    replace: \"hi\"")

        described_class.append(file, snippet_yaml)

        content = File.read(file)
        # The trigger key must never appear on the same line as a replace value
        expect(content).not_to match(/replace:.*- trigger/)
        expect(content).not_to match(/replace:.*- triggers/)
        expect(content).not_to match(/replace:.*- regex/)
        expect(content).to include("    replace: \"hi\"\n  - trigger:")
      end
    end

    context 'with multi-line replacement snippet' do
      let(:snippet_yaml) do
        <<~YAML
          - trigger: ":sig"
            replace: |
              Best regards,
              AJ
        YAML
      end

      it 'indents all lines by 2 spaces' do
        file = File.join(@tmpdir, 'base.yml')
        File.write(file, "matches:\n")

        described_class.append(file, snippet_yaml)

        content = File.read(file)
        expect(content).to include('  - trigger:')
        expect(content).to include('    replace: |')
        expect(content).to include('      Best regards,')
      end
    end
  end
end
