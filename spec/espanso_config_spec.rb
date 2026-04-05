# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/espanso_config'

RSpec.describe SnippetCli::EspansoConfig do
  let(:success_status) { instance_double(Process::Status, success?: true) }
  let(:failure_status) { instance_double(Process::Status, success?: false) }

  describe '.match_dir' do
    it 'parses the Config line from espanso path output' do
      espanso_output = "Config: /home/user/.config/espanso\n" \
                       "Packages: /home/user/.local/share/espanso\nRuntime: /tmp/espanso\n"
      allow(Open3).to receive(:capture2).with('espanso', 'path').and_return([espanso_output, success_status])

      expect(described_class.match_dir).to eq('/home/user/.config/espanso/match')
    end

    it 'raises when espanso path command fails' do
      allow(Open3).to receive(:capture2).with('espanso', 'path').and_return(['', failure_status])

      expect { described_class.match_dir }.to raise_error(SnippetCli::EspansoConfigError, /could not determine/i)
    end

    it 'raises when Config line is not found in output' do
      allow(Open3).to receive(:capture2).with('espanso', 'path').and_return(["Packages: /tmp\n", success_status])

      expect { described_class.match_dir }.to raise_error(SnippetCli::EspansoConfigError, /could not determine/i)
    end
  end

  describe '.match_files' do
    it 'returns sorted yml files from the match directory' do
      match_dir = '/home/user/.config/espanso/match'
      allow(described_class).to receive(:match_dir).and_return(match_dir)
      allow(Dir).to receive(:glob)
        .with(File.join(match_dir, '**', '*.yml'), sort: true)
        .and_return(["#{match_dir}/base.yml", "#{match_dir}/code.yml",
                     "#{match_dir}/packages/all-emojis.yml"])

      expect(described_class.match_files).to eq(
        ["#{match_dir}/base.yml", "#{match_dir}/code.yml",
         "#{match_dir}/packages/all-emojis.yml"]
      )
    end

    it 'returns empty array when no yml files exist' do
      allow(described_class).to receive(:match_dir).and_return('/tmp/empty/match')
      allow(Dir).to receive(:glob).and_return([])

      expect(described_class.match_files).to eq([])
    end
  end
end
