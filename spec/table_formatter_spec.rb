# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/table_formatter'

ANSI_STRIP = /\e\[[0-9;]*m/

RSpec.describe SnippetCli::TableFormatter do
  describe '.render' do
    it 'wraps output in white ANSI color' do
      result = described_class.render([['foo']], headers: ['Name'])
      expect(result).to start_with("\e[97m")
      expect(result).to end_with("\e[0m")
    end

    it 'renders a single-column table sized to the header' do
      result = described_class.render([['foo'], ['bar']], headers: ['Trigger']).gsub(ANSI_STRIP, '')
      expect(result).to eq(<<~TABLE.chomp)
        ╭─────────╮
        │ Trigger │
        ├─────────┤
        │ foo     │
        │ bar     │
        ╰─────────╯
      TABLE
    end

    it 'renders a two-column table' do
      result = described_class.render([%w[dt date]], headers: %w[Name Type]).gsub(ANSI_STRIP, '')
      expect(result).to eq(<<~TABLE.chomp)
        ╭──────┬──────╮
        │ Name │ Type │
        ├──────┼──────┤
        │ dt   │ date │
        ╰──────┴──────╯
      TABLE
    end

    it 'sizes columns to content when content is wider than header' do
      result = described_class.render([%w[a_very_long_name echo]], headers: %w[Name Type]).gsub(ANSI_STRIP, '')
      expect(result).to include('│ a_very_long_name │')
      expect(result).to start_with('╭──────────────────')
    end

    it 'renders multiple rows with consistent alignment' do
      result = described_class.render([%w[foo echo], %w[bar shell]], headers: %w[Name Type]).gsub(ANSI_STRIP, '')
      expect(result).to eq(<<~TABLE.chomp)
        ╭──────┬───────╮
        │ Name │ Type  │
        ├──────┼───────┤
        │ foo  │ echo  │
        │ bar  │ shell │
        ╰──────┴───────╯
      TABLE
    end
  end
end
