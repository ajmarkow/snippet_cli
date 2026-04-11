# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnippetCli::Commands::Version do
  subject(:command) { described_class.new }

  it 'renders the version via UI.info' do
    allow(SnippetCli::UI).to receive(:info)
    command.call
    expect(SnippetCli::UI).to have_received(:info).with(/#{Regexp.escape(SnippetCli::VERSION)}/)
  end
end
