# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/var_builder'

RSpec.describe SnippetCli::VarBuilder do
  describe '.run' do
    context 'when user declines to add any variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(false)
        allow($stdout).to receive(:puts)
      end

      it 'returns an empty array' do
        expect(described_class.run[:vars]).to eq([])
      end
    end

    context 'when user adds an echo variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('greeting')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('John')
        allow($stdout).to receive(:puts)
      end

      it 'stores the value under the :echo key in params' do
        var = described_class.run[:vars].first
        expect(var[:params][:echo]).to eq('John')
      end

      it 'does not use :value as the params key' do
        var = described_class.run[:vars].first
        expect(var[:params]).not_to have_key(:value)
      end
    end

    context 'when user adds a shell variable' do
      before do
        # First loop: "Add a variable?" → vars empty; after add: "Add another variable?"
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Enable debug mode?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('myvar')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('shell')
        allow(Gum).to receive(:filter).with(*described_class.platform_shells, limit: 1,
                                                                              header: 'Select shell').and_return('bash')
        allow(Gum).to receive(:input).with(placeholder: 'shell command').and_return('date')
        allow($stdout).to receive(:puts)
      end

      it 'returns one var' do
        expect(described_class.run[:vars].size).to eq(1)
      end

      it 'has name, type, cmd, and shell in params' do
        var = described_class.run[:vars].first
        expect(var[:name]).to eq('myvar')
        expect(var[:type]).to eq('shell')
        expect(var[:params][:cmd]).to eq('date')
        expect(var[:params][:shell]).to eq('bash')
      end

      it 'includes trim when true' do
        var = described_class.run[:vars].first
        expect(var[:params][:trim]).to eq(true)
      end

      it 'omits debug when false' do
        var = described_class.run[:vars].first
        expect(var[:params]).not_to have_key(:debug)
      end
    end

    context 'when user adds a script variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('result')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('script')
        allow(Gum).to receive(:write).and_return("/usr/bin/my_script\n--flag")
        allow($stdout).to receive(:puts)
      end

      it 'splits args by line' do
        var = described_class.run[:vars].first
        expect(var[:params][:args]).to eq(['/usr/bin/my_script', '--flag'])
      end

      it 'does not prompt for debug' do
        expect(Gum).not_to receive(:confirm).with('Enable debug mode?', prompt_style: anything)
        described_class.run
      end

      it 'omits trim when user declines' do
        var = described_class.run[:vars].first
        expect(var[:params]).not_to have_key(:trim)
      end

      context 'when user enables trim' do
        before do
          allow(Gum).to receive(:confirm).with('Trim whitespace from output?', prompt_style: anything).and_return(true)
        end

        it 'includes trim: true in params' do
          var = described_class.run[:vars].first
          expect(var[:params][:trim]).to eq(true)
        end
      end
    end

    context 'when user adds a date variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add an offset?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a locale?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a timezone?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('dt')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('date')
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow($stdout).to receive(:puts)
      end

      it 'prompts for offset (date-specific)' do
        expect(Gum).to receive(:confirm).with('Add an offset?', prompt_style: anything).and_return(false)
        described_class.run
      end

      it 'prompts for locale (date-specific)' do
        expect(Gum).to receive(:confirm).with('Add a locale?', prompt_style: anything).and_return(false)
        described_class.run
      end

      it 'prompts for timezone (date-specific)' do
        expect(Gum).to receive(:confirm).with('Add a timezone?', prompt_style: anything).and_return(false)
        described_class.run
      end

      it 'stores format in params' do
        var = described_class.run[:vars].first
        expect(var[:params][:format]).to eq('%Y-%m-%d')
      end

      it 'omits offset when user declines' do
        var = described_class.run[:vars].first
        expect(var[:params]).not_to have_key(:offset)
      end

      it 'omits locale when user declines' do
        var = described_class.run[:vars].first
        expect(var[:params]).not_to have_key(:locale)
      end

      it 'omits tz when user declines' do
        var = described_class.run[:vars].first
        expect(var[:params]).not_to have_key(:tz)
      end

      context 'when user adds an offset' do
        before do
          allow(Gum).to receive(:confirm).with('Add an offset?', prompt_style: anything).and_return(true)
          allow(Gum).to receive(:input).with(placeholder: 'offset in seconds (e.g. 86400)').and_return('86400')
        end

        it 'stores offset as an integer in params' do
          var = described_class.run[:vars].first
          expect(var[:params][:offset]).to eq(86_400)
        end
      end

      context 'when user adds a locale' do
        before do
          allow(Gum).to receive(:confirm).with('Add a locale?', prompt_style: anything).and_return(true)
          allow(Gum).to receive(:input).with(placeholder: 'BCP47 locale (e.g. en-US, ja-JP)').and_return('ja-JP')
        end

        it 'stores locale as a string in params' do
          var = described_class.run[:vars].first
          expect(var[:params][:locale]).to eq('ja-JP')
        end
      end

      context 'when user adds a timezone' do
        before do
          allow(Gum).to receive(:confirm).with('Add a timezone?', prompt_style: anything).and_return(true)
          allow(Gum).to receive(:input).with(placeholder: 'IANA timezone (e.g. America/New_York)')
                                       .and_return('America/New_York')
        end

        it 'stores tz as a string in params' do
          var = described_class.run[:vars].first
          expect(var[:params][:tz]).to eq('America/New_York')
        end
      end
    end

    context 'when user adds a non-date variable (echo)' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('greeting')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hello')
        allow($stdout).to receive(:puts)
      end

      it 'does not prompt for offset' do
        expect(Gum).not_to receive(:confirm).with('Add an offset?', prompt_style: anything)
        described_class.run
      end

      it 'does not prompt for locale' do
        expect(Gum).not_to receive(:confirm).with('Add a locale?', prompt_style: anything)
        described_class.run
      end
    end

    context 'when user adds a form variable' do
      let(:field_types) { described_class::FormFields::FIELD_TYPES }

      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('myform')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('form')
        allow($stdout).to receive(:puts)
      end

      context 'when user selects multi-line form' do
        before do
          allow(Gum).to receive(:confirm).with('Multi-line form?', prompt_style: anything).and_return(true)
          allow(Gum).to receive(:write).with(hash_including(header: a_string_including('layout')))
                                       .and_return("Enter your name: [[name]]\nEnter city: [[city]]")
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_matching(/field type/i))
                                        .and_return('Single-line text box', 'Single-line text box')
        end

        it 'collects layout via gum write' do
          expect(Gum).to receive(:write).with(hash_including(header: a_string_including('layout')))
                                        .and_return('Enter your name: [[name]]')
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_matching(/field type/i))
                                        .and_return('Single-line text box')
          described_class.run
        end

        it 'stores the multiline layout in params' do
          var = described_class.run[:vars].first
          expect(var[:params][:layout]).to eq("Enter your name: [[name]]\nEnter city: [[city]]")
        end
      end

      context 'when user selects single-line form' do
        before do
          allow(Gum).to receive(:confirm).with('Multi-line form?', prompt_style: anything).and_return(false)
          allow(Gum).to receive(:input).with(hash_including(placeholder: a_string_including('layout')))
                                       .and_return('Name: [[name]]')
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_matching(/field type/i))
                                        .and_return('Single-line text box')
        end

        it 'collects layout via gum input' do
          expect(Gum).to receive(:input).with(hash_including(placeholder: a_string_including('layout')))
                                        .and_return('Name: [[name]]')
          described_class.run
        end

        it 'stores the single-line layout in params' do
          var = described_class.run[:vars].first
          expect(var[:params][:layout]).to eq('Name: [[name]]')
        end

        it 'does not use gum write for layout' do
          expect(Gum).not_to receive(:write)
          described_class.run
        end
      end

      context 'field type selection' do
        before do
          allow(Gum).to receive(:confirm).with('Multi-line form?', prompt_style: anything).and_return(false)
          allow(Gum).to receive(:input).with(hash_including(placeholder: a_string_including('layout')))
                                       .and_return('Name: [[name]] City: [[city]]')
        end

        it 'prompts for each field type' do
          expect(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                             header: a_string_including('name'))
                                         .and_return('Single-line text box').ordered
          expect(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                             header: a_string_including('city'))
                                         .and_return('Single-line text box').ordered
          described_class.run
        end

        it 'omits fields key when all fields are single-line text box' do
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_matching(/field type/i))
                                        .and_return('Single-line text box')
          var = described_class.run[:vars].first
          expect(var[:params]).not_to have_key(:fields)
        end

        it 'sets multiline: true for Multiline text box fields' do
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('name'))
                                        .and_return('Multi-line text box')
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('city'))
                                        .and_return('Single-line text box')
          var = described_class.run[:vars].first
          expect(var[:params][:fields]).to eq({ name: { multiline: true } })
        end

        it 'collects values for Choice box fields' do
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('name'))
                                        .and_return('Choice box')
          allow(Gum).to receive(:input).with(placeholder: 'name value (blank to finish)')
                                       .and_return('Alice', 'Bob', '')
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('city'))
                                        .and_return('Single-line text box')
          var = described_class.run[:vars].first
          expect(var[:params][:fields]).to eq({ name: { type: :choice, values: %w[Alice Bob] } })
        end

        it 'collects values for List box fields' do
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('name'))
                                        .and_return('List box')
          allow(Gum).to receive(:input).with(placeholder: 'name value (blank to finish)')
                                       .and_return('Alice', 'Bob', '')
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('city'))
                                        .and_return('Single-line text box')
          var = described_class.run[:vars].first
          expect(var[:params][:fields]).to eq({ name: { type: :list, values: %w[Alice Bob] } })
        end

        it 'requires more than one value for Choice box fields' do
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('name'))
                                        .and_return('Choice box')
          # First attempt: only one value, re-prompted; second attempt: two values
          allow(Gum).to receive(:input).with(placeholder: 'name value (blank to finish)')
                                       .and_return('Alice', '', 'Alice', 'Bob', '')
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('city'))
                                        .and_return('Single-line text box')
          expect(SnippetCli::UI).to receive(:warning).with(a_string_matching(/at least 2/i))
          var = described_class.run[:vars].first
          expect(var[:params][:fields][:name][:values]).to eq(%w[Alice Bob])
        end

        it 'requires more than one value for List box fields' do
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('name'))
                                        .and_return('List box')
          allow(Gum).to receive(:input).with(placeholder: 'name value (blank to finish)')
                                       .and_return('Alice', '', 'Alice', 'Bob', '')
          allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                            header: a_string_including('city'))
                                        .and_return('Single-line text box')
          expect(SnippetCli::UI).to receive(:warning).with(a_string_matching(/at least 2/i))
          var = described_class.run[:vars].first
          expect(var[:params][:fields][:name][:values]).to eq(%w[Alice Bob])
        end
      end
    end

    context 'when user adds a clipboard variable' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('clip')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type')
                                      .and_return('clipboard')
        allow($stdout).to receive(:puts)
      end

      it 'returns a clipboard var with empty params' do
        var = described_class.run[:vars].first
        expect(var[:type]).to eq('clipboard')
        expect(var[:params]).to eq({})
      end

      it 'does not prompt for debug' do
        expect(Gum).not_to receive(:confirm).with('Enable debug mode?', prompt_style: anything)
        described_class.run
      end

      it 'does not prompt for trim' do
        expect(Gum).not_to receive(:confirm).with('Trim whitespace from output?', prompt_style: anything)
        described_class.run
      end
    end

    context 'duplicate name detection' do
      before do
        # Flow: add 'myvar' → try 'myvar' again (dup, next) → stop
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another variable?'), prompt_style: anything)
          .and_return(true, false)
        allow(Gum).to receive(:confirm).with('Enable debug mode?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input)
          .with(hash_including(placeholder: 'Your variable name')).and_return('myvar', 'myvar')
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
        vars = described_class.run[:vars]
        expect(vars.count { |v| v[:name] == 'myvar' }).to eq(1)
      end
    end

    context 'summary display' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add an offset?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a locale?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a timezone?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('dt')
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

      it 'calls UI.note with {{var}} syntax explanation' do
        expect(SnippetCli::UI).to receive(:note).with(a_string_including('{{var}}'))
        described_class.run
      end

      it 'calls UI.note showing the actual variable name in normal braces' do
        expect(SnippetCli::UI).to receive(:note).with(a_string_including('{{dt}}'))
        described_class.run
      end

      it 'calls UI.note with a multiline message' do
        expect(SnippetCli::UI).to receive(:note).with(a_string_including("\n"))
        described_class.run
      end
    end

    context 'summary display with multiple vars' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another variable?'), prompt_style: anything)
          .and_return(true, false)
        allow(Gum).to receive(:confirm).with('Add an offset?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a locale?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a timezone?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('dt', 'cmd')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1, header: 'Variable type').and_return(
          'date', 'shell'
        )
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow(Gum).to receive(:filter).with(*described_class.platform_shells, limit: 1,
                                                                              header: 'Select shell').and_return('bash')
        allow(Gum).to receive(:input).with(placeholder: 'shell command').and_return('whoami')
        allow(Gum).to receive(:confirm).with('Enable debug mode?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?', prompt_style: anything).and_return(false)
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

    context 'mid-flow table with form variable' do
      let(:field_types) { described_class::FormFields::FIELD_TYPES }

      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with('Multi-line form?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name'))
                                     .and_return('test', 'greeting')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type')
                                      .and_return('form', 'echo')
        allow(Gum).to receive(:input).with(hash_including(placeholder: a_string_including('layout')))
                                     .and_return('Name: [[field1]] City: [[field2]]')
        allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                          header: a_string_matching(/field type/i))
                                      .and_return('Single-line text box')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hi')
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'shows form fields with dot notation in the mid-flow confirm' do
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another variable?'), prompt_style: anything)
          .and_return(true, false)
        expect(Gum).to receive(:confirm)
          .with(a_string_including('test.field1').and(a_string_including('test.field2')),
                prompt_style: anything)
        described_class.run
      end

      it 'shows form field type in the mid-flow confirm' do
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another variable?'), prompt_style: anything)
          .and_return(true, false)
        expect(Gum).to receive(:confirm)
          .with(a_string_including('form field'), prompt_style: anything)
        described_class.run
      end

      it 'does not show the bare form var name in the mid-flow confirm' do
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another variable?'), prompt_style: anything)
          .and_return(true, false)
        expect(Gum).not_to receive(:confirm)
          .with(a_string_matching(/│ test\s+│ form\s+│/), prompt_style: anything)
        described_class.run
      end
    end

    context 'summary display with form variable' do
      let(:field_types) { described_class::FormFields::FIELD_TYPES }

      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Multi-line form?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('myform')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('form')
        allow(Gum).to receive(:write).with(hash_including(header: a_string_including('layout')))
                                     .and_return("Name: [[name]]\nCity: [[city]]")
        allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                          header: a_string_matching(/field type/i))
                                      .and_return('Single-line text box')
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'expands form fields as individual rows with dot notation names' do
        expect(Gum).to receive(:table).with(
          [['myform.name', 'form field'], ['myform.city', 'form field']],
          columns: %w[Name Type],
          print: true
        )
        described_class.run
      end

      it 'shows field reference syntax in the note' do
        expect(SnippetCli::UI).to receive(:note).with(
          a_string_including('{{myform.name}}').and(a_string_including('{{myform.city}}'))
        )
        described_class.run
      end

      it 'does not show the form var itself as a row' do
        expect(Gum).to receive(:table) do |rows, **_|
          expect(rows).not_to include(%w[myform form])
        end
        described_class.run
      end
    end

    context 'summary display with form and non-form variables' do
      let(:field_types) { described_class::FormFields::FIELD_TYPES }

      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add another variable?'), prompt_style: anything)
          .and_return(true, false)
        allow(Gum).to receive(:confirm).with('Multi-line form?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('myform',
                                                                                                         'greeting')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('form',
                                                                                                             'echo')
        allow(Gum).to receive(:input).with(hash_including(placeholder: a_string_including('layout')))
                                     .and_return('Hi [[name]]')
        allow(Gum).to receive(:filter).with(*field_types, limit: 1,
                                                          header: a_string_matching(/field type/i))
                                      .and_return('Single-line text box')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hello')
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'renders form fields and regular vars together' do
        expect(Gum).to receive(:table).with(
          [['myform.name', 'form field'], %w[greeting echo]],
          columns: %w[Name Type],
          print: true
        )
        described_class.run
      end
    end
  end

  describe '.confirm! styling' do
    before { allow($stdout).to receive(:puts) }

    it 'does not include a border in prompt_style' do
      allow(Gum).to receive(:confirm).and_return(false)
      described_class.run
      expect(Gum).to have_received(:confirm)
        .with(anything, prompt_style: hash_not_including(:border))
    end

    it 'does not include a border-foreground color in prompt_style' do
      allow(Gum).to receive(:confirm).and_return(false)
      described_class.run
      expect(Gum).to have_received(:confirm)
        .with(anything, prompt_style: hash_not_including(:'border-foreground'))
    end
  end

  describe 'Ctrl+C interrupt' do
    before { allow($stdout).to receive(:puts) }

    it 'raises WizardInterrupted when Gum.confirm exits with 130 (Ctrl+C)' do
      allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything) do
        system('exit 130')
        false
      end

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Ruby raises Interrupt (SIGINT during Gum.confirm)' do
      allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_raise(Interrupt)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Gum.input returns nil mid-variable' do
      allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
      allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return(nil)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Gum.filter returns nil' do
      allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
      allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('myvar')
      allow(Gum).to receive(:filter).and_return(nil)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end

    it 'raises WizardInterrupted when Gum.input returns nil during choice value collection' do
      allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
      allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('myvar')
      allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                       header: 'Variable type').and_return('choice')
      allow(Gum).to receive(:input).with(placeholder: 'value (blank to finish)').and_return(nil)

      expect { described_class.run }.to raise_error(SnippetCli::WizardInterrupted)
    end
  end

  describe '.run with skip_initial_prompt: true' do
    context 'when user adds one variable then declines to add another' do
      before do
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('dt')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('date')
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow(Gum).to receive(:confirm).with('Add an offset?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a locale?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a timezone?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with(a_string_including('Add an additional variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'does not ask "Add a variable?" before collecting the first variable' do
        expect(Gum).not_to receive(:confirm).with('Add a variable?', prompt_style: anything)
        described_class.run(skip_initial_prompt: true)
      end

      it 'collects the first variable immediately without confirmation' do
        vars = described_class.run(skip_initial_prompt: true)[:vars]
        expect(vars.first[:name]).to eq('dt')
      end

      it 'asks "Add an additional variable?" after the first variable' do
        expect(Gum).to receive(:confirm).with(a_string_including('Add an additional variable?'),
                                              prompt_style: anything).and_return(false)
        described_class.run(skip_initial_prompt: true)
      end

      it 'returns only the one variable when user declines' do
        vars = described_class.run(skip_initial_prompt: true)[:vars]
        expect(vars.size).to eq(1)
      end
    end

    context 'when user adds two variables then declines' do
      before do
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('dt', 'cmd')
        allow(Gum).to receive(:filter)
          .with(*described_class::VAR_TYPES, limit: 1, header: 'Variable type')
          .and_return('date', 'shell')
        allow(Gum).to receive(:input).with(placeholder: 'date format (e.g. %Y-%m-%d)').and_return('%Y-%m-%d')
        allow(Gum).to receive(:confirm).with('Add an offset?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a locale?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Add a timezone?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:filter).with(*described_class.platform_shells, limit: 1,
                                                                              header: 'Select shell').and_return('bash')
        allow(Gum).to receive(:input).with(placeholder: 'shell command').and_return('date')
        allow(Gum).to receive(:confirm).with('Enable debug mode?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm).with('Trim whitespace from output?', prompt_style: anything).and_return(false)
        allow(Gum).to receive(:confirm)
          .with(a_string_including('Add an additional variable?'), prompt_style: anything)
          .and_return(true, false)
        allow(Gum).to receive(:table)
        allow($stdout).to receive(:puts)
      end

      it 'returns two variables' do
        vars = described_class.run(skip_initial_prompt: true)[:vars]
        expect(vars.size).to eq(2)
      end

      it 'does not ask "Add another variable?" (old prompt text)' do
        expect(Gum).not_to receive(:confirm).with('Add another variable?', prompt_style: anything)
        described_class.run(skip_initial_prompt: true)
      end
    end
  end

  describe 'empty name validation' do
    context 'when user enters an empty name' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input)
          .with(hash_including(placeholder: 'Your variable name')).and_return('', 'good_name')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hello')
        allow(Gum).to receive(:table)
        allow(SnippetCli::UI).to receive(:info)
        allow(SnippetCli::UI).to receive(:warning)
        allow($stdout).to receive(:puts)
      end

      it 'warns that the name cannot be empty via UI.warning' do
        described_class.run
        expect(SnippetCli::UI).to have_received(:warning).with(/cannot be empty/i)
      end

      it 're-prompts and accepts the next non-empty name' do
        vars = described_class.run[:vars]
        expect(vars.first[:name]).to eq('good_name')
      end
    end
  end

  describe 'prohibited character validation' do
    context 'when user enters a name containing a hyphen' do
      before do
        # collect_one_var now loops internally on prohibited char — re-prompts immediately.
        # Provide a valid second name so the loop can exit.
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input)
          .with(hash_including(placeholder: 'Your variable name')).and_return('bad-name', 'good_name')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hello')
        allow(Gum).to receive(:table)
        allow(SnippetCli::UI).to receive(:info)
        allow(SnippetCli::UI).to receive(:warning)
        allow($stdout).to receive(:puts)
      end

      it 'warns about the prohibited character via UI.warning' do
        described_class.run
        expect(SnippetCli::UI).to have_received(:warning).with(/prohibited/i)
      end

      it 'does not add bad-name to the collected variables' do
        vars = described_class.run[:vars]
        expect(vars.map { |v| v[:name] }).not_to include('bad-name')
      end

      it 'mentions the hyphen in the warning' do
        described_class.run
        expect(SnippetCli::UI).to have_received(:warning).with(/-/)
      end
    end

    context 'when user enters a valid name (letters, digits, underscores)' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('my_var_2')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hello')
        allow(Gum).to receive(:table)
        allow(SnippetCli::UI).to receive(:info)
        allow($stdout).to receive(:puts)
      end

      it 'accepts the variable without warnings' do
        expect { described_class.run }.not_to output.to_stderr
      end

      it 'adds the variable to the result' do
        vars = described_class.run[:vars]
        expect(vars.first[:name]).to eq('my_var_2')
      end
    end

    context 'when user enters an invalid name then a valid one' do
      before do
        # collect_one_var loops internally after prohibited char — only one "Add a variable?"
        # confirm is needed before the valid name is accepted.
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input)
          .with(hash_including(placeholder: 'Your variable name')).and_return('bad-name', 'good_name')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hello')
        allow(Gum).to receive(:table)
        allow(SnippetCli::UI).to receive(:info)
        allow(SnippetCli::UI).to receive(:warning)
        allow($stdout).to receive(:puts)
      end

      it 'only adds the valid variable' do
        vars = described_class.run[:vars]
        expect(vars.size).to eq(1)
        expect(vars.first[:name]).to eq('good_name')
      end
    end
  end

  describe ':summary_clear in run result' do
    context 'when no vars are added' do
      before do
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(false)
        allow($stdout).to receive(:puts)
      end

      it 'returns a callable' do
        result = described_class.run
        expect(result[:summary_clear]).to respond_to(:call)
      end
    end

    context 'after run with vars' do
      before do
        allow($stdout).to receive(:tty?).and_return(true)
        allow($stdout).to receive(:print)
        allow(Gum).to receive(:confirm).with('Add a variable?', prompt_style: anything).and_return(true)
        allow(Gum).to receive(:confirm).with(a_string_including('Add another variable?'),
                                             prompt_style: anything).and_return(false)
        allow(Gum).to receive(:input).with(hash_including(placeholder: 'Your variable name')).and_return('myvar')
        allow(Gum).to receive(:filter).with(*described_class::VAR_TYPES, limit: 1,
                                                                         header: 'Variable type').and_return('echo')
        allow(Gum).to receive(:input).with(placeholder: 'echo value').and_return('hi')
        allow(Gum).to receive(:table)
        allow(SnippetCli::UI).to receive(:info)
        allow($stdout).to receive(:puts)
      end

      it 'returns a callable that can erase the summary' do
        result = described_class.run
        expect(result[:summary_clear]).to respond_to(:call)
      end

      it 'summary_clear moves cursor up past note AND table (not just note)' do
        # text = "Reference your variables...\n{{myvar}}" → 2 lines
        # total = (2 + 1) note+blank + (1 + 4) table + 1 blank = 9
        result = described_class.run
        printed = []
        allow($stdout).to receive(:print) { |arg| printed << arg }
        result[:summary_clear].call
        expect(printed).to include(TTY::Cursor.up(9))
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
