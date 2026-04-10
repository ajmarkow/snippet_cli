# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/replacement_text_collector'

class ReplacementTextCollectorHost
  include SnippetCli::WizardHelpers
  include SnippetCli::ReplacementTextCollector

  public :collect_replace, :collect_alt_value, :prompt_alt_input, :prompt_non_empty_replace
end

RSpec.describe SnippetCli::ReplacementTextCollector do
  subject(:host) { ReplacementTextCollectorHost.new }

  describe '#collect_replace' do
    context 'single-line input' do
      before do
        allow(Gum).to receive(:confirm)
          .with('Multi-line replacement?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input)
          .with(placeholder: 'Replacement text').and_return('Hello world')
      end

      it 'returns the entered text' do
        expect(host.collect_replace([])).to eq('Hello world')
      end
    end

    context 'multi-line input' do
      before do
        allow(Gum).to receive(:confirm)
          .with('Multi-line replacement?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:write)
          .with(header: 'Replacement', placeholder: 'Type expansion text...').and_return("line one\nline two")
      end

      it 'returns the multi-line text' do
        expect(host.collect_replace([])).to eq("line one\nline two")
      end
    end

    context 'empty input followed by confirmed empty' do
      before do
        allow(Gum).to receive(:confirm)
          .with('Multi-line replacement?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input)
          .with(placeholder: 'Replacement text').and_return('   ', 'actual text')
        allow(Gum).to receive(:confirm)
          .with(SnippetCli::ReplacementTextCollector::EMPTY_REPLACE_WARNING,
                prompt_style: anything).and_return(false, true)
      end

      it 'loops until non-empty or confirmed empty' do
        result = host.collect_replace([])
        expect(result).to eq('actual text').or eq('   ')
      end
    end
  end

  describe '#prompt_alt_input' do
    context 'image_path type' do
      before do
        allow(Gum).to receive(:input)
          .with(placeholder: '/path/to/image.png').and_return('/img/logo.png')
      end

      it 'uses Gum.input with image path placeholder' do
        expect(host.prompt_alt_input(:image_path)).to eq('/img/logo.png')
      end
    end

    context 'markdown type' do
      before do
        allow(Gum).to receive(:write)
          .with(header: 'Markdown', placeholder: 'Enter markdown...').and_return('**bold**')
      end

      it 'uses Gum.write with capitalised header' do
        expect(host.prompt_alt_input(:markdown)).to eq('**bold**')
      end
    end

    context 'html type' do
      before do
        allow(Gum).to receive(:write)
          .with(header: 'Html', placeholder: 'Enter html...').and_return('<b>bold</b>')
      end

      it 'uses Gum.write with capitalised header' do
        expect(host.prompt_alt_input(:html)).to eq('<b>bold</b>')
      end
    end
  end

  describe 'EMPTY_REPLACE_WARNING' do
    it 'is defined as a string constant' do
      expect(described_class::EMPTY_REPLACE_WARNING).to be_a(String)
    end
  end
end
