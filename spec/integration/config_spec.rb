RSpec.describe "`snippet_cli setup` command", type: :cli do
  it "executes `snippet_cli help setup` command successfully" do
    output = `snippet_cli help setup`
    expected_output = <<-OUT
Usage:
  snippet_cli setup

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
