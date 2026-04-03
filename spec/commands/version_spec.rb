# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnippetCli::Commands::Version do
  subject(:command) { described_class.new }

  it 'prints the version in a normal-line box' do
    expect { command.call }.to output(/╔═+╗.*VERSION #{Regexp.escape(SnippetCli::VERSION)}.*╚═+╝/m).to_stdout
  end
end
