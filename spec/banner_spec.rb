# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/banner'

RSpec.describe SnippetCli do
  describe '.banner' do
    before do
      allow(Gum::Command).to receive(:run_non_interactive).and_return('styled banner')
    end

    it 'passes the figlet art via stdin to gum style' do
      described_class.banner
      expect(Gum::Command).to have_received(:run_non_interactive)
        .with('style', anything, anything, anything, anything, input: a_string_including('┏━┓┏┓╻╻'))
    end

    it 'uses --border=thick' do
      described_class.banner
      expect(Gum::Command).to have_received(:run_non_interactive)
        .with('style', '--border=thick', anything, anything, anything, input: anything)
    end

    it 'uses --border-foreground=075 for accent color' do
      described_class.banner
      expect(Gum::Command).to have_received(:run_non_interactive)
        .with('style', anything, anything, anything, '--border-foreground=075', input: anything)
    end

    it 'uses --align=center to center the figlet art' do
      described_class.banner
      expect(Gum::Command).to have_received(:run_non_interactive)
        .with('style', anything, anything, '--align=center', anything, input: anything)
    end

    it 'returns the rendered string' do
      expect(described_class.banner).to eq('styled banner')
    end
  end
end
