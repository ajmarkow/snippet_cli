require 'snippet_cli/commands/config'

RSpec.describe SnippetCli::Commands::Config do
  it "executes `config` command successfully" do
    output = StringIO.new
    options = {}
    command = SnippetCli::Commands::Config.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
