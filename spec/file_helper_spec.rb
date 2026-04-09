# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/file_helper'
require 'tempfile'

RSpec.describe SnippetCli::FileHelper do
  describe '.ensure_readable!' do
    context 'when the file exists' do
      it 'returns without error' do
        file = Tempfile.new('readable')
        file.close
        expect { described_class.ensure_readable!(file.path) }.not_to raise_error
        file.unlink
      end
    end

    context 'when the file does not exist' do
      it 'writes a not-found message to stderr' do
        expect { described_class.ensure_readable!('/no/such/file.yml') }
          .to raise_error(SystemExit)
          .and output(%r{not found.*no/such/file\.yml}i).to_stderr
      end

      it 'exits with status 1' do
        expect { described_class.ensure_readable!('/no/such/file.yml') }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end
    end
  end

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
