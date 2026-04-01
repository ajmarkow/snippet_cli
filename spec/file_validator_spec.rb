# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/file_validator'

RSpec.describe SnippetCli::FileValidator do
  def load(fixture)
    YAML.safe_load_file(
      File.join(__dir__, 'fixtures', fixture),
      symbolize_names: false
    ) || {}
  end

  # ── valid fixtures ──────────────────────────────────────────────────────────

  describe 'valid matchfiles' do
    it 'accepts the minimal valid matchfile' do
      expect(described_class.valid?(load('valid_matchfile.yml'))).to be true
    end

    it 'returns no errors for the minimal valid matchfile' do
      expect(described_class.errors(load('valid_matchfile.yml'))).to be_empty
    end

    it 'accepts a comprehensive matchfile with all var types, forms, html, markdown' do
      expect(described_class.valid?(load('valid_matchfile_full.yml'))).to be true
    end

    it 'returns no errors for the comprehensive matchfile' do
      expect(described_class.errors(load('valid_matchfile_full.yml'))).to be_empty
    end
  end

  # ── top-level structure ─────────────────────────────────────────────────────

  describe 'top-level structure' do
    it 'rejects a file missing the matches key' do
      expect(described_class.valid?(load('invalid_matchfile.yml'))).to be false
    end

    it 'rejects unknown top-level keys (additionalProperties: false)' do
      expect(described_class.valid?(load('invalid_unknown_top_level_key.yml'))).to be false
    end

    it 'accepts matches + global_vars + imports together' do
      data = {
        'matches' => [{ 'trigger' => ':t', 'replace' => 'x' }],
        'global_vars' => [{ 'name' => 'v', 'type' => 'echo', 'params' => { 'echo' => 'hi' } }],
        'imports' => ['/path/to/file.yml']
      }
      expect(described_class.valid?(data)).to be true
    end
  end

  # ── trigger requirement ─────────────────────────────────────────────────────

  describe 'trigger requirement' do
    it 'rejects a match with no trigger, triggers, or regex' do
      expect(described_class.valid?(load('invalid_missing_trigger.yml'))).to be false
    end

    it 'accepts trigger' do
      data = { 'matches' => [{ 'trigger' => ':t', 'replace' => 'x' }] }
      expect(described_class.valid?(data)).to be true
    end

    it 'accepts triggers (array)' do
      data = { 'matches' => [{ 'triggers' => [':t', ':tt'], 'replace' => 'x' }] }
      expect(described_class.valid?(data)).to be true
    end

    it 'accepts regex' do
      data = { 'matches' => [{ 'regex' => ':(hi|hey)', 'replace' => 'x' }] }
      expect(described_class.valid?(data)).to be true
    end
  end

  # ── replacement requirement ─────────────────────────────────────────────────

  describe 'replacement requirement' do
    it 'rejects a match with trigger but no replacement' do
      expect(described_class.valid?(load('invalid_missing_replacement.yml'))).to be false
    end

    it 'accepts replace' do
      data = { 'matches' => [{ 'trigger' => ':t', 'replace' => 'text' }] }
      expect(described_class.valid?(data)).to be true
    end

    it 'accepts form' do
      data = { 'matches' => [{ 'trigger' => ':t', 'form' => 'Fill: [[field]]' }] }
      expect(described_class.valid?(data)).to be true
    end

    it 'accepts image_path' do
      data = { 'matches' => [{ 'trigger' => ':t', 'image_path' => '/img.png' }] }
      expect(described_class.valid?(data)).to be true
    end

    it 'accepts html' do
      data = { 'matches' => [{ 'trigger' => ':t', 'html' => '<b>bold</b>' }] }
      expect(described_class.valid?(data)).to be true
    end

    it 'accepts markdown' do
      data = { 'matches' => [{ 'trigger' => ':t', 'markdown' => '**bold**' }] }
      expect(described_class.valid?(data)).to be true
    end
  end

  # ── var types ───────────────────────────────────────────────────────────────

  describe 'var type validation' do
    def match_with_var(type:, params:)
      {
        'matches' => [{
          'trigger' => ':t', 'replace' => '{{v}}',
          'vars' => [{ 'name' => 'v', 'type' => type, 'params' => params }]
        }]
      }
    end

    it 'accepts echo var' do
      expect(described_class.valid?(match_with_var(type: 'echo', params: { 'echo' => 'hi' }))).to be true
    end

    it 'accepts date var with format' do
      expect(described_class.valid?(match_with_var(type: 'date', params: { 'format' => '%Y-%m-%d' }))).to be true
    end

    it 'accepts shell var with cmd' do
      expect(described_class.valid?(match_with_var(type: 'shell', params: { 'cmd' => 'whoami' }))).to be true
    end

    it 'accepts random var with choices' do
      expect(described_class.valid?(match_with_var(type: 'random', params: { 'choices' => %w[a b c] }))).to be true
    end

    it 'accepts script var with args' do
      args = ['ruby', '/path/to/script.rb', 'extra', 'args']
      expect(described_class.valid?(match_with_var(type: 'script', params: { 'args' => args }))).to be true
    end

    it 'accepts choice var with values' do
      params = { 'values' => %w[yes no maybe] }
      expect(described_class.valid?(match_with_var(type: 'choice', params: params))).to be true
    end

    it 'accepts clipboard var (no params required)' do
      data = {
        'matches' => [{
          'trigger' => ':t', 'replace' => '{{v}}',
          'vars' => [{ 'name' => 'v', 'type' => 'clipboard' }]
        }]
      }
      expect(described_class.valid?(data)).to be true
    end

    it 'rejects a var with an unknown type' do
      expect(described_class.valid?(load('invalid_bad_var_type.yml'))).to be false
    end
  end

  # ── error messages ──────────────────────────────────────────────────────────

  describe '#errors' do
    it 'returns an array of strings' do
      errs = described_class.errors(load('invalid_matchfile.yml'))
      expect(errs).to be_an(Array)
      expect(errs).to all(be_a(String))
    end

    it 'includes pointer context in error messages for nested failures' do
      errs = described_class.errors(load('invalid_missing_trigger.yml'))
      expect(errs.join).to match(/matches/)
    end
  end
end
