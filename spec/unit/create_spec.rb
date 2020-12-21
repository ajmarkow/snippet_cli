require 'snippet_cli/commands/create'

RSpec.describe SnippetCli::Commands::Create do
  it "executes `create` command successfully" do
    output = StringIO.new
    options = {}
    command = SnippetCli::Commands::Create.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
