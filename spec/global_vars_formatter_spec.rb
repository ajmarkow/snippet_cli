# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/global_vars_formatter'

RSpec.describe SnippetCli::GlobalVarsFormatter do
  let(:var_entries) { "  - name: dt\n    type: date\n    params:\n      format: \"%Y-%m-%d\"\n" }

  describe '.build_content' do
    context 'when existing content is empty' do
      it 'creates global_vars key with entries' do
        result = described_class.build_content('', var_entries)
        expect(result).to start_with("global_vars:\n")
        expect(result).to include('- name: dt')
      end

      it 'ends with a trailing newline' do
        result = described_class.build_content('', var_entries)
        expect(result).to end_with("\n")
      end
    end

    context 'when existing content has matches but no global_vars' do
      let(:existing) { "matches:\n  - trigger: \":hello\"\n    replace: \"Hello!\"\n" }

      it 'appends global_vars after existing content' do
        result = described_class.build_content(existing, var_entries)
        expect(result).to include("global_vars:\n")
        expect(result).to include('- name: dt')
      end

      it 'preserves existing matches' do
        result = described_class.build_content(existing, var_entries)
        expect(result).to include('trigger: ":hello"')
      end
    end

    context 'when existing content already has a global_vars block' do
      let(:existing) { "global_vars:\n  - name: existing\n    type: echo\n    params:\n      echo: hi\n" }

      it 'inserts new entries into the existing block' do
        result = described_class.build_content(existing, var_entries)
        expect(result).to include('name: existing')
        expect(result).to include('name: dt')
      end

      it 'does not duplicate the global_vars key' do
        result = described_class.build_content(existing, var_entries)
        expect(result.scan(/^global_vars:/).length).to eq(1)
      end
    end

    context 'when existing content has global_vars followed by matches' do
      let(:existing) do
        "global_vars:\n  - name: existing\n    type: echo\n    params:\n      echo: hi\n\n" \
          "matches:\n  - trigger: \":hello\"\n    replace: \"Hello!\"\n"
      end

      it 'inserts new vars before matches section' do
        result = described_class.build_content(existing, var_entries)
        expect(result.index('name: dt')).to be < result.index('matches:')
      end

      it 'preserves matches' do
        result = described_class.build_content(existing, var_entries)
        expect(result).to include('trigger: ":hello"')
      end
    end
  end
end
