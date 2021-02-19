require 'snippet_cli/commands/new'

RSpec.describe SnippetCli::Commands::New do
  it "executes `new` command successfully" do
    output = StringIO.new
    options = {}
    command = SnippetCli::Commands::New.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
