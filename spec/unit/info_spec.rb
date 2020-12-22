require 'snippet_cli/commands/info'

RSpec.describe SnippetCli::Commands::Info do
  it "executes `info` command successfully" do
    output = StringIO.new
    docs = nil
    options = {}
    command = SnippetCli::Commands::Info.new(docs, options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
