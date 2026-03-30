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

  describe '.preview' do
    include_examples 'passes text via stdin', :preview
    include_examples 'handles YAML-prefixed text without error', :preview

    it 'passes --border=double flag' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.preview('text')

      expect(received_args).to include('--border=double')
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

    it 'passes error border styling' do
      received_args = nil
      allow(Gum::Command).to receive(:run_non_interactive) do |*args, **|
        received_args = args
        'styled'
      end
      allow($stdout).to receive(:puts)

      described_class.error('text')

      args = received_args.join(' ')
      expect(args).to include('border-foreground=196')
      expect(args).to include('--bold')
    end
  end
end
