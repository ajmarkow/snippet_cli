require 'snippet_cli/commands/setup'

RSpec.describe SnippetCli::Commands::Setup do
  it "executes `setup` command successfully" do
    output = StringIO.new
    options = {}
    command = SnippetCli::Commands::Setup.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
