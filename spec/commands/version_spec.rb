# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnippetCli::Commands::Version do
  subject(:command) { described_class.new }

  it 'prints the current version' do
    expect { command.call }.to output("#{SnippetCli::VERSION}\n").to_stdout
  end
end
