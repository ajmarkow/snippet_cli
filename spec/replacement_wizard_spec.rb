# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/replacement_wizard'

RSpec.describe SnippetCli::ReplacementWizard do
  subject(:wizard) { described_class.new }

  before { system('true') } # reset $? so stale 130 exits don't fire WizardInterrupted

  def stub_confirm(text, result)
    allow(Gum).to receive(:confirm).with(text, prompt_style: anything).and_return(result)
  end

  describe '#collect_plain_replace' do
    it 'prompts for replacement text and returns it' do
      allow(Gum).to receive(:confirm).with('Multi-line replacement?', prompt_style: anything).and_return(false)
      allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return('hello world')
      expect(wizard.collect_plain_replace).to eq('hello world')
    end
  end

  describe '#collect' do
    context 'when user picks plain replacement' do
      before do
        stub_confirm('Use a non-plaintext replacement type?', false)
        stub_confirm('Multi-line replacement?', false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Replacement text')).and_return('simple text')
      end

      it 'returns a hash with replace key' do
        result = wizard.collect([], global_var_names: [])
        expect(result).to include(replace: 'simple text')
      end
    end

    context 'when user picks an alt type (markdown)' do
      before do
        stub_confirm('Use a non-plaintext replacement type?', true)
        allow(Gum).to receive(:filter).with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
                                      .and_return('markdown')
        allow(Gum).to receive(:write).with(hash_including(header: 'Markdown'))
                                     .and_return('**bold**')
      end

      it 'returns a hash with the markdown key' do
        result = wizard.collect([], global_var_names: [])
        expect(result).to include(markdown: '**bold**')
      end
    end

    context 'when user picks image_path with no vars' do
      before do
        stub_confirm('Use a non-plaintext replacement type?', true)
        allow(Gum).to receive(:filter).with('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type')
                                      .and_return('image_path')
        allow(Gum).to receive(:input).with(hash_including(placeholder: '/path/to/image.png')).and_return('/img.png')
      end

      it 'returns image_path key and vars: []' do
        result = wizard.collect([], global_var_names: [])
        expect(result).to include(image_path: '/img.png', vars: [])
      end
    end
  end

  describe '#collect_advanced_options' do
    context 'when user declines advanced options' do
      before { stub_confirm('Show advanced options?', false) }

      it 'returns default hash with nil label, nil comment, empty search_terms' do
        result = wizard.collect_advanced_options
        expect(result).to eq(label: nil, comment: nil, search_terms: [])
      end

      it 'does not prompt for individual advanced fields' do
        wizard.collect_advanced_options
        expect(Gum).not_to have_received(:confirm).with('Add a label?', anything)
        expect(Gum).not_to have_received(:confirm).with('Word trigger?', anything)
      end
    end

    context 'when user accepts advanced options' do
      before do
        stub_confirm('Show advanced options?', true)
        stub_confirm('Add a label?', false)
        stub_confirm('Add a comment?', false)
        stub_confirm('Add search terms?', false)
        stub_confirm('Word trigger?', false)
        stub_confirm('Propagate case?', false)
      end

      it 'returns a hash with all advanced keys' do
        result = wizard.collect_advanced_options
        expect(result).to have_key(:label)
        expect(result).to have_key(:comment)
        expect(result).to have_key(:search_terms)
      end

      it 'passes word: true when user confirms word trigger' do
        stub_confirm('Word trigger?', true)
        result = wizard.collect_advanced_options
        expect(result[:word]).to be(true)
      end

      it 'passes propagate_case: true when user confirms propagate case' do
        stub_confirm('Propagate case?', true)
        result = wizard.collect_advanced_options
        expect(result[:propagate_case]).to be(true)
      end
    end
  end
end
