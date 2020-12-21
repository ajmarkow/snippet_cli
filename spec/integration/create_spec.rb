RSpec.describe "`snippet_cli create` command", type: :cli do
  it "executes `snippet_cli help create` command successfully" do
    output = `snippet_cli help create`
    expected_output = <<-OUT
Usage:
  snippet_cli create

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
