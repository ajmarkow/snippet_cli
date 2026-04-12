# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/wizard_helpers/match_file_selector'
require 'snippet_cli/espanso_config'

class MatchFileSelectorTestHost
  include SnippetCli::WizardHelpers::MatchFileSelector
  include SnippetCli::WizardHelpers::PromptHelpers

  public :pick_match_file
end

RSpec.describe SnippetCli::WizardHelpers::MatchFileSelector do
  subject(:host) { MatchFileSelectorTestHost.new }

  describe '#pick_match_file' do
    context 'when exactly one match file exists' do
      before do
        allow(SnippetCli::EspansoConfig).to receive(:match_files).and_return(['/config/match/base.yml'])
      end

      it 'does not prompt via Gum.filter' do
        allow(Gum).to receive(:filter)
        host.pick_match_file
        expect(Gum).not_to have_received(:filter)
      end

      it 'returns the basename and full path' do
        expect(host.pick_match_file).to eq(['base.yml', '/config/match/base.yml'])
      end
    end

    context 'when multiple match files exist' do
      before do
        allow(SnippetCli::EspansoConfig).to receive(:match_files)
          .and_return(['/config/match/base.yml', '/config/match/extras.yml'])
        allow(Gum).to receive(:filter).and_return('base.yml')
      end

      it 'prompts via Gum.filter' do
        host.pick_match_file
        expect(Gum).to have_received(:filter)
      end
    end

    context 'when no match files exist' do
      before { allow(SnippetCli::EspansoConfig).to receive(:match_files).and_return([]) }

      it 'raises NoMatchFilesError' do
        expect { host.pick_match_file }.to raise_error(SnippetCli::NoMatchFilesError)
      end
    end
  end
end
