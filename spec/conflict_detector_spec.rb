# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/conflict_detector'

RSpec.describe SnippetCli::ConflictDetector do
  describe '.extract_triggers' do
    subject(:entries) { described_class.extract_triggers(yaml) }

    context 'with empty content' do
      let(:yaml) { '' }

      it { is_expected.to eq([]) }
    end

    context 'with no matches key' do
      let(:yaml) { "other_key:\n  - value\n" }

      it { is_expected.to eq([]) }
    end

    context 'with matches: nil' do
      let(:yaml) { "matches:\n" }

      it { is_expected.to eq([]) }
    end

    context 'with a single trigger' do
      let(:yaml) do
        <<~YAML
          matches:
            - trigger: ":hello"
              replace: "Hello!"
        YAML
      end

      it 'returns one entry' do
        expect(entries.length).to eq(1)
      end

      it 'captures the trigger value' do
        expect(entries.first[:trigger]).to eq(':hello')
      end

      it 'captures the line number' do
        expect(entries.first[:line]).to be_a(Integer)
      end
    end

    context 'with a triggers array' do
      let(:yaml) do
        <<~YAML
          matches:
            - triggers:
                - ":bye"
                - ":goodbye"
              replace: "Goodbye!"
        YAML
      end

      it 'returns one entry per trigger in the array' do
        expect(entries.length).to eq(2)
      end

      it 'captures all trigger values' do
        expect(entries.map { |e| e[:trigger] }).to contain_exactly(':bye', ':goodbye')
      end
    end

    context 'with a regex key' do
      let(:yaml) do
        <<~YAML
          matches:
            - regex: ":(gr|great)ing"
              replace: "Greetings!"
        YAML
      end

      it 'returns one entry' do
        expect(entries.length).to eq(1)
      end

      it 'captures the regex as trigger value' do
        expect(entries.first[:trigger]).to eq(':(gr|great)ing')
      end
    end

    context 'with a match missing trigger/triggers/regex' do
      let(:yaml) do
        <<~YAML
          matches:
            - replace: "orphan"
        YAML
      end

      it 'skips the match silently' do
        expect(entries).to eq([])
      end
    end

    context 'with duplicate triggers (fixture file)' do
      let(:yaml) { File.read(File.join(__dir__, 'fixtures/duplicate_triggers.yml')) }

      it 'finds :hello twice' do
        hello_entries = entries.select { |e| e[:trigger] == ':hello' }
        expect(hello_entries.length).to eq(2)
      end

      it 'finds :bye twice (once in triggers array, once standalone)' do
        bye_entries = entries.select { |e| e[:trigger] == ':bye' }
        expect(bye_entries.length).to eq(2)
      end

      it 'includes line numbers for all entries' do
        expect(entries).to all(include(:trigger, :line))
        expect(entries.map { |e| e[:line] }).to all(be_a(Integer))
      end
    end
  end
end
