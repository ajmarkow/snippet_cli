# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/file_helper'
require 'tempfile'

RSpec.describe SnippetCli::FileHelper do
  describe '.read_or_empty' do
    context 'when the file exists' do
      it 'returns the file contents' do
        file = Tempfile.new('test')
        file.write('hello world')
        file.close
        expect(described_class.read_or_empty(file.path)).to eq('hello world')
        file.unlink
      end
    end

    context 'when the file does not exist' do
      it 'returns an empty string' do
        expect(described_class.read_or_empty('/nonexistent/path/file.txt')).to eq('')
      end
    end
  end
end
