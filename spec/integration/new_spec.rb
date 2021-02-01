RSpec.describe "`snippet_cli new` command", type: :cli do
  it "executes `snippet_cli help new` command successfully" do
    output = `snippet_cli help new`
    expected_output = <<-OUT
Usage:
  snippet_cli new

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
