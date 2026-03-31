# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/var_builder'

RSpec.describe SnippetCli::VarBuilder do
  describe '.run' do
    context 'when user declines to add any variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?').and_return(false)
        allow($stdout).to receive(:puts)
      end

      it 'returns an empty array' do
        expect(described_class.run).to eq([])
      end
    end

    context 'when user adds an echo variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?')).and_return(false)
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('greeting')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('John')
        allow($stdout).to receive(:puts)
      end

      it 'stores the value under the :echo key in params' do
        var = described_class.run.first
        expect(var[:params][:echo]).to eq('John')
      end

      it 'does not use :value as the params key' do
        var = described_class.run.first
        expect(var[:params]).not_to have_key(:value)
      end
    end

    context 'when user adds a shell variable' do
      before do
        # First loop: "Add a variable?" → vars empty; after add: "Add another variable?"
        allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?')).and_return(false)
        allow(Gum).to receive(:confirm).with('Enable debug mode?').and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?').and_return(true)
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('myvar')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('shell')
        allow(Gum).to receive(:filter).with(*described_class.platform_shells, limit: 1,
                                                                              header: 'Select shell').and_return('bash')
        allow(Gum).to receive(:input).with(placeholder: 'shell command').and_return('date')
        allow($stdout).to receive(:puts)
      end

      it 'returns one var' do
        expect(described_class.run.size).to eq(1)
      end

      it 'has name, type, cmd, and shell in params' do
        var = described_class.run.first
        expect(var[:name]).to eq('myvar')
        expect(var[:type]).to eq('shell')
        expect(var[:params][:cmd]).to eq('date')
        expect(var[:params][:shell]).to eq('bash')
      end

      it 'includes trim when true' do
        var = described_class.run.first
        expect(var[:params][:trim]).to eq(true)
      end

      it 'omits debug when false' do
        var = described_class.run.first
        expect(var[:params]).not_to have_key(:debug)
      end
    end

    context 'when user adds a script variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?')).and_return(false)
        allow(Gum).to receive(:confirm).with('Enable debug mode?').and_return(true)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?').and_return(false)
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('result')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('script')
        allow(Gum).to receive(:write).and_return("/usr/bin/my_script\n--flag")
        allow($stdout).to receive(:puts)
      end

      it 'splits args by line' do
        var = described_class.run.first
        expect(var[:params][:args]).to eq(['/usr/bin/my_script', '--flag'])
      end

      it 'includes debug when true' do
        var = described_class.run.first
        expect(var[:params][:debug]).to eq(true)
      end

      it 'omits trim when false' do
        var = described_class.run.first
        expect(var[:params]).not_to have_key(:trim)
      end
    end

    context 'duplicate name detection' do
      before do
        # Flow: add 'myvar' → try 'myvar' again (dup, next) → stop
        allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?')).and_return(true, false)
        allow(Gum).to receive(:confirm).with('Enable debug mode?').and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?').and_return(false)
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('myvar', 'myvar')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('shell')
        allow(Gum).to receive(:filter).with(*described_class.platform_shells, limit: 1,
                                                                              header: 'Select shell').and_return('bash')
        allow(Gum).to receive(:input).with(placeholder: 'shell command').and_return('date')
        allow($stdout).to receive(:puts)
      end

      it 'warns about the duplicate' do
        expect { described_class.run }.to output(/already defined/i).to_stderr
      end

      it 'includes the var only once' do
        vars = described_class.run
        expect(vars.count { |v| v[:name] == 'myvar' }).to eq(1)
      end
    end

    context 'summary display' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?')).and_return(false)
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('dt')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('date')
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'renders a Gum table with Name and Type columns' do
        expect(Gum).to receive(:table).with(
          [%w[dt date]],
          columns: %w[Name Type],
          print: true
        )
        described_class.run
      end

      it 'calls UI.info with {{var}} syntax explanation' do
        expect(SnippetCli::UI).to receive(:info).with(a_string_including('{{var}}'))
        described_class.run
      end

      it 'calls UI.info showing the actual variable name in double braces' do
        expect(SnippetCli::UI).to receive(:info).with(a_string_including('{{dt}}'))
        described_class.run
      end

      it 'calls UI.info with a multiline message' do
        expect(SnippetCli::UI).to receive(:info).with(a_string_including("\n"))
        described_class.run
      end
    end

    context 'summary display with multiple vars' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?')).and_return(true, false)
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('dt', 'cmd')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1, header: 'Variable type').and_return(
          'date', 'shell'
        )
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow(Gum).to receive(:filter).with(*described_class.platform_shells, limit: 1,
                                                                              header: 'Select shell').and_return('bash')
        allow(Gum).to receive(:input).with(placeholder: 'shell command').and_return('whoami')
        allow(Gum).to receive(:confirm).with('Enable debug mode?').and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?').and_return(false)
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'renders all vars in one final table' do
        expect(Gum).to receive(:table).with(
          [%w[dt date], %w[cmd shell]],
          columns: %w[Name Type],
          print: true
        ).once

        described_class.run
      end
    end
  end

  describe 'Ctrl+C interrupt' do
    before { allow($stdout).to receive(:puts) }

    it 'raises WizardInterrupted when Gum.confirm exits with 130 (Ctrl+C)' do
      allow(Gum).to receive(:confirm).with('Add a variable?') do
        system('exit 130')
        false
      end

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Ruby raises Interrupt (SIGINT during Gum.confirm)' do
      allow(Gum).to receive(:confirm).with('Add a variable?').and_raise(Interrupt)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Gum.input returns nil mid-variable' do
      allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
      allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return(nil)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Gum.filter returns nil' do
      allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
      allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('myvar')
      allow(Gum).to receive(:filter).and_return(nil)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Gum.input returns nil during choice value collection' do
      allow(Gum).to receive(:confirm).with('Add a variable?').and_return(true)
      allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('myvar')
      allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                       header: 'Variable type').and_return('choice')
      allow(Gum).to receive(:input).with(placeholder: 'value (blank to finish)').and_return(nil)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end
  end

  describe '.run with skip_initial_prompt: true' do
    context 'when user adds one variable then declines to add another' do
      before do
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('dt')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('date')
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow(Gum).to receive(:confirm).with(a_string_including('Add an additional variable?')).and_return(false)
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'does not ask "Add a variable?" before collecting the first variable' do
        expect(Gum).not_to receive(:confirm).with('Add a variable?')
        described_class.run(skip_initial_prompt: true)
      end

      it 'collects the first variable immediately without confirmation' do
        vars = described_class.run(skip_initial_prompt: true)
        expect(vars.first[:name]).to eq('dt')
      end

      it 'asks "Add an additional variable?" after the first variable' do
        expect(Gum).to receive(:confirm).with(a_string_including('Add an additional variable?')).and_return(false)
        described_class.run(skip_initial_prompt: true)
      end

      it 'returns only the one variable when user declines' do
        vars = described_class.run(skip_initial_prompt: true)
        expect(vars.size).to eq(1)
      end
    end

    context 'when user adds two variables then declines' do
      before do
        allow(Gum).to receive(:input).with(placeholder: 'Your variable name').and_return('dt', 'cmd')
        allow(Gum).to receive(:filter)
          .with(*described_class::VAR_TYPES, limit: 1, header: 'Variable type')
          .and_return('date', 'shell')
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow(Gum).to receive(:filter).with(*described_class.platform_shells, limit: 1,
                                                                              header: 'Select shell').and_return('bash')
        allow(Gum).to receive(:input).with(placeholder: 'shell command').and_return('date')
        allow(Gum).to receive(:confirm).with('Enable debug mode?').and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?').and_return(false)
        allow(Gum).to receive(:confirm).with(a_string_including('Add an additional variable?')).and_return(true, false)
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'returns two variables' do
        vars = described_class.run(skip_initial_prompt: true)
        expect(vars.size).to eq(2)
      end

      it 'does not ask "Add another variable?" (old prompt text)' do
        expect(Gum).not_to receive(:confirm).with('Add another variable?')
        described_class.run(skip_initial_prompt: true)
      end
    end
  end

  describe '.platform_shells' do
    it 'returns an Array of strings' do
      expect(described_class.platform_shells).to be_an(Array)
      expect(described_class.platform_shells).to all(be_a(String))
    end

    it 'always includes sh or cmd' do
      shells = described_class.platform_shells
      expect(shells).to include('sh').or include('cmd')
    end
  end
end
