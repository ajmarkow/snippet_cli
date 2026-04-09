# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/cursor_helper'

RSpec.describe SnippetCli::CursorHelper do
  describe '.build_erase_lambda' do
    context 'when stdout is not a TTY' do
      before { allow($stdout).to receive(:tty?).and_return(false) }

      it 'returns a no-op lambda' do
        result = described_class.build_erase_lambda(5)
        expect(result).to be_a(Proc)
        expect { result.call }.not_to output.to_stdout
      end
    end

    context 'when stdout is a TTY' do
      before { allow($stdout).to receive(:tty?).and_return(true) }

      it 'returns a lambda that moves the cursor up by line_count' do
        allow($stdout).to receive(:print)
        allow(TTY::Cursor).to receive(:up).with(3).and_return("\e[3A")
        allow(TTY::Cursor).to receive(:clear_screen_down).and_return("\e[J")

        described_class.build_erase_lambda(3).call

        expect(TTY::Cursor).to have_received(:up).with(3)
      end

      it 'returns a lambda that clears the screen down' do
        allow($stdout).to receive(:print)
        allow(TTY::Cursor).to receive(:up).and_return("\e[3A")
        allow(TTY::Cursor).to receive(:clear_screen_down).and_return("\e[J")

        described_class.build_erase_lambda(3).call

        expect(TTY::Cursor).to have_received(:clear_screen_down)
      end
    end
  end
end
