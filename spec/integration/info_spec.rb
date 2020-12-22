RSpec.describe "`snippet_cli info` command", type: :cli do
  it "executes `snippet_cli help info` command successfully" do
    output = `snippet_cli help info`
    expected_output = <<-OUT
Usage:
  snippet_cli info [DOCS]

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
