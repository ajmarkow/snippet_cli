# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/ui'

RSpec.describe SnippetCli::UI do
  # All UI methods must pass text via stdin to Gum::Command.run_non_interactive,
  # never as a positional CLI argument. Passing YAML text (which starts with
  # "- triggers:") as a positional arg causes gum to misparse "- " as an
  # unknown flag and raise Gum::Error.
  shared_examples 'passes text via stdin' do |method, *_extra_flag_patterns|
    it 'calls Gum::Command.run_non_interactive with text as :input (not positional)' do
      received_input = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*_args, input:, **|
        received_input = input
        'styled output'
      end
      allow($stdout).to receive(:puts)

      described_class.public_send(method, 'some text')

      expect(received_input).to eq('some text')
    end

    it 'does not pass text as a positional CLI argument' do
      received_positional = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_positional = args
        'styled output'
      end
      allow($stdout).to receive(:puts)

      described_class.public_send(method, 'some text')

      expect(received_positional).not_to include('some text')
    end
  end

  # Regression: YAML text beginning with "- " (a list marker) was passed as a
  # positional arg to `gum style`, which parsed "- " as an unknown flag `-`.
  shared_examples 'handles YAML-prefixed text without error' do |method|
    it 'does not raise when text starts with a YAML list marker (- )' do
      allow(Gum::Command).to receive(:run_non_interactive).and_return('styled')
      allow($stdout).to receive(:puts)

      yaml_text = "- triggers:\n    - ':test'\n  replace: 'hi'\n"
      expect { described_class.public_send(method, yaml_text) }.not_to raise_error
    end
  end

  describe '.transient_warning' do
    it 'always calls UI.warning with the text regardless of TTY' do
      allow($stdout).to receive(:tty?).and_return(false)
      expect(described_class).to receive(:warning).with('something went wrong')
      described_class.transient_warning('something went wrong')
    end

    it 'returns a callable' do
      allow(described_class).to receive(:warning)
      expect(described_class.transient_warning('text')).to respond_to(:call)
    end

    it 'returned lambda is a no-op when stdout is not a TTY' do
      allow($stdout).to receive(:tty?).and_return(false)
      allow(described_class).to receive(:warning)
      clear = described_class.transient_warning('text')
      expect { clear.call }.not_to output.to_stdout
    end

    it 'returned lambda moves cursor up by text line count + 2 borders' do
      allow($stdout).to receive(:tty?).and_return(true)
      allow(described_class).to receive(:warning)
      printed = []
      allow($stdout).to receive(:print) { |arg| printed << arg }

      clear = described_class.transient_warning("line one\nline two") # 2 lines → up by 4
      clear.call

      expect(printed).to include(TTY::Cursor.up(4))
    end

    it 'returned lambda clears screen down after moving cursor up' do
      allow($stdout).to receive(:tty?).and_return(true)
      allow(described_class).to receive(:warning)
      printed = []
      allow($stdout).to receive(:print) { |arg| printed << arg }

      clear = described_class.transient_warning('one line')
      clear.call

      expect(printed).to include(TTY::Cursor.clear_screen_down)
    end
  end

  describe '.transient_info' do
    it 'always calls UI.info with the text regardless of TTY' do
      allow($stdout).to receive(:tty?).and_return(false)
      expect(described_class).to receive(:info).with('note')
      described_class.transient_info('note')
    end

    it 'returns a callable' do
      allow(described_class).to receive(:info)
      expect(described_class.transient_info('text')).to respond_to(:call)
    end

    it 'returned lambda is a no-op when stdout is not a TTY' do
      allow($stdout).to receive(:tty?).and_return(false)
      allow(described_class).to receive(:info)
      clear = described_class.transient_info('note')
      expect { clear.call }.not_to output.to_stdout
    end

    it 'returned lambda moves cursor up by text line count + 2 borders' do
      allow($stdout).to receive(:tty?).and_return(true)
      allow(described_class).to receive(:info)
      printed = []
      allow($stdout).to receive(:print) { |arg| printed << arg }

      clear = described_class.transient_info('one line') # 1 line → up by 3
      clear.call

      expect(printed).to include(TTY::Cursor.up(3))
    end

    it 'returned lambda clears screen down' do
      allow($stdout).to receive(:tty?).and_return(true)
      allow(described_class).to receive(:info)
      printed = []
      allow($stdout).to receive(:print) { |arg| printed << arg }

      clear = described_class.transient_info('text')
      clear.call

      expect(printed).to include(TTY::Cursor.clear_screen_down)
    end
  end

  describe '.format_code' do
    it 'uses Gum::Command.run_display_only so gum writes directly to the TTY (enabling color)' do
      allow(Gum::Command).to receive(:run_display_only).and_return(true)

      described_class.format_code('vars: []', language: 'yaml')

      expect(Gum::Command).to have_received(:run_display_only)
        .with('format', '--type=code', '--language=yaml', input: 'vars: []')
    end

    it 'falls back to puts when run_display_only raises' do
      allow(Gum::Command).to receive(:run_display_only).and_raise(Gum::Error)

      expect { described_class.format_code('vars: []', language: 'yaml') }
        .to output("vars: []\n\n").to_stdout
    end
  end

  describe '.preview' do
    include_examples 'passes text via stdin', :preview
    include_examples 'handles YAML-prefixed text without error', :preview

    it 'passes --border=normal flag' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.preview('text')

      expect(received_args).to include('--border=normal')
    end
  end

  describe '.info' do
    include_examples 'passes text via stdin', :info
    include_examples 'handles YAML-prefixed text without error', :info
  end

  describe '.hint' do
    include_examples 'passes text via stdin', :hint
    include_examples 'handles YAML-prefixed text without error', :hint

    it 'passes a border-foreground flag' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.hint('text')

      expect(received_args.join(' ')).to include('border-foreground')
    end
  end

  describe '.success' do
    include_examples 'passes text via stdin', :success
    include_examples 'handles YAML-prefixed text without error', :success

    it 'passes --bold flag' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.success('text')

      expect(received_args).to include('--bold')
    end
  end

  describe '.error' do
    include_examples 'passes text via stdin', :error
    include_examples 'handles YAML-prefixed text without error', :error

    it 'passes error border and text styling' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.error('text')

      args = received_args.join(' ')
      expect(args).to include('border-foreground=196')
      expect(args).to include('--foreground=196')
      expect(args).to include('--bold')
    end
  end

  describe '.warning' do
    include_examples 'passes text via stdin', :warning
    include_examples 'handles YAML-prefixed text without error', :warning

    it 'passes yellow border-foreground flag' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.warning('text')

      expect(received_args.join(' ')).to include('border-foreground=220')
    end

    it 'passes yellow foreground flag for text color' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.warning('text')

      expect(received_args.join(' ')).to include('--foreground=220')
    end

    it 'passes --bold flag' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.warning('text')

      expect(received_args).to include('--bold')
    end
  end
end
