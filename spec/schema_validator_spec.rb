# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/schema_validator'

RSpec.describe SnippetCli::SchemaValidator do
  let(:valid_data) { { 'matches' => [{ 'trigger' => ':t', 'replace' => 'hello' }] } }
  let(:invalid_data) { { 'matches' => [{ 'replace' => 'no trigger' }] } }

  describe '.valid?' do
    it 'returns true for valid matchfile data' do
      expect(described_class.valid?(valid_data)).to be true
    end

    it 'returns false for invalid matchfile data' do
      expect(described_class.valid?(invalid_data)).to be false
    end
  end

  describe '.validate' do
    it 'returns an empty enumerator for valid data' do
      expect(described_class.validate(valid_data).to_a).to be_empty
    end

    it 'returns error objects for invalid data' do
      errors = described_class.validate(invalid_data).to_a
      expect(errors).not_to be_empty
    end

    it 'returns error objects that respond to [] for key access' do
      error = described_class.validate(invalid_data).first
      expect(error).to respond_to(:[])
    end
  end

  describe 'schemer memoization' do
    it 'returns the same schemer instance on repeated calls' do
      expect(described_class.send(:schemer)).to be(described_class.send(:schemer))
    end
  end
end
