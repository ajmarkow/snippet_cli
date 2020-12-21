RSpec.describe "`snippet_cli config` command", type: :cli do
  it "executes `snippet_cli help config` command successfully" do
    output = `snippet_cli help config`
    expected_output = <<-OUT
Usage:
  snippet_cli config

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
