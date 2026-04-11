# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/file_writer'
require 'tmpdir'

RSpec.describe SnippetCli::FileWriter do
  around do |example|
    Dir.mktmpdir do |dir|
      @tmpdir = dir
      example.run
    end
  end

  describe '.write' do
    it 'creates the file with the given content' do
      file = File.join(@tmpdir, 'out.yml')

      described_class.write(file, "matches:\n")

      expect(File.read(file)).to eq("matches:\n")
    end

    it 'overwrites existing file content' do
      file = File.join(@tmpdir, 'out.yml')
      File.write(file, 'old content')

      described_class.write(file, 'new content')

      expect(File.read(file)).to eq('new content')
    end
  end
end
