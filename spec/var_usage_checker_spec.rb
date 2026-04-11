# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/var_usage_checker'

RSpec.describe SnippetCli::VarUsageChecker do
  def warnings(vars, replacement)
    described_class.match_warnings(vars, replacement)
  end

  let(:echo_var) { { name: 'greeting', type: 'echo', params: { echo: 'Hello' } } }
  let(:shell_var) { { name: 'user', type: 'shell', params: { cmd: 'whoami' } } }

  context 'when vars are properly used in replace:' do
    it 'returns no warnings' do
      result = warnings([echo_var], { replace: 'Hi {{greeting}}' })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'when vars are properly used in html:' do
    it 'returns no warnings' do
      result = warnings([echo_var], { html: '<b>{{greeting}}</b>' })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'when vars are properly used in markdown:' do
    it 'returns no warnings' do
      result = warnings([echo_var], { markdown: '**{{greeting}}**' })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'when vars are properly used in image_path:' do
    it 'returns no warnings' do
      result = warnings([echo_var], { image_path: '/imgs/{{greeting}}.png' })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'when a declared var is unused' do
    it 'includes the var name in unused' do
      result = warnings([echo_var], { replace: 'Hello World' })
      expect(result[:unused]).to include('greeting')
    end

    it 'returns one entry per unused var' do
      result = warnings([echo_var, shell_var], { replace: 'static text' })
      expect(result[:unused].length).to eq(2)
    end
  end

  context 'when a var ref is used but not declared' do
    it 'includes the var name in undeclared' do
      result = warnings([], { replace: 'Hello {{ghost}}' })
      expect(result[:undeclared]).to include('ghost')
    end

    it 'detects undeclared refs in html: field' do
      result = warnings([], { html: '<b>{{ghost}}</b>' })
      expect(result[:undeclared]).to include('ghost')
    end

    it 'detects undeclared refs in markdown: field' do
      result = warnings([], { markdown: '**{{ghost}}**' })
      expect(result[:undeclared]).to include('ghost')
    end

    it 'detects undeclared refs in image_path: field' do
      result = warnings([], { image_path: '/imgs/{{ghost}}.png' })
      expect(result[:undeclared]).to include('ghost')
    end
  end

  context 'when there are no vars and no references' do
    it 'returns no warnings' do
      result = warnings([], { replace: 'plain text' })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'when vars array is empty' do
    it 'returns no warnings for plain replacement' do
      result = warnings([], { replace: 'hello' })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'with mixed declared/undeclared/unused' do
    it 'returns warnings only for problematic vars' do
      vars = [echo_var, shell_var]
      # greeting used ✓, user unused ✗, ghost undeclared ✗
      result = warnings(vars, { replace: 'Hi {{greeting}} and {{ghost}}' })
      expect(result[:unused]).to contain_exactly('user')
      expect(result[:undeclared]).to contain_exactly('ghost')
    end
  end

  context 'with global_var_names' do
    def warnings_with_globals(vars, replacement, global_var_names:)
      described_class.match_warnings(vars, replacement, global_var_names: global_var_names)
    end

    it 'suppresses undeclared warning when var is in global_var_names' do
      result = warnings_with_globals([], { replace: 'Today is {{dt}}' }, global_var_names: %w[dt])
      expect(result[:undeclared]).to be_empty
    end

    it 'still warns for vars not in local or global' do
      result = warnings_with_globals([], { replace: '{{dt}} {{ghost}}' }, global_var_names: %w[dt])
      expect(result[:undeclared]).to contain_exactly('ghost')
    end

    it 'does not suppress unused-local-var warnings' do
      result = warnings_with_globals([echo_var], { replace: 'Today is {{dt}}' }, global_var_names: %w[dt])
      expect(result[:unused]).to contain_exactly('greeting')
      expect(result[:undeclared]).to be_empty
    end

    it 'handles mix of local vars and global vars' do
      result = warnings_with_globals([echo_var], { replace: 'Hi {{greeting}} on {{dt}}' }, global_var_names: %w[dt])
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'with form variables' do
    let(:form_layout) do
      "I went to [[city]].\nThe weather was [[adjective]].\n" \
        "We ate [[food]].\nWhat a [[unit_of_time]]."
    end
    let(:form_var) do
      { name: 'laughing', type: 'form', params: { layout: form_layout } }
    end

    it 'returns no warnings when all form fields are used' do
      replace = '{{laughing.city}} {{laughing.adjective}} ' \
                '{{laughing.food}} {{laughing.unit_of_time}}'
      result = warnings([form_var], { replace: replace })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end

    it 'includes unused form fields in unused' do
      result = warnings([form_var], { replace: '{{laughing.city}}' })
      expect(result[:unused]).to include('laughing.adjective', 'laughing.food', 'laughing.unit_of_time')
    end

    it 'includes undeclared form field references in undeclared' do
      result = warnings([form_var], { replace: '{{laughing.city}} {{laughing.bogus}}' })
      expect(result[:undeclared]).to include('laughing.bogus')
    end

    it 'does not treat the form var name itself as a declared name' do
      result = warnings([form_var], { replace: '{{laughing}}' })
      expect(result[:undeclared]).to include('laughing')
    end

    it 'works alongside non-form vars' do
      vars = [form_var, echo_var]
      replace = '{{laughing.city}} {{laughing.adjective}} ' \
                '{{laughing.food}} {{laughing.unit_of_time}} {{greeting}}'
      result = warnings(vars, { replace: replace })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end

  context 'with string-keyed var hashes (from YAML load)' do
    it 'handles string keys gracefully' do
      string_var = { 'name' => 'greeting', 'type' => 'echo', 'params' => { 'echo' => 'Hello' } }
      result = warnings([string_var], { replace: 'Hi {{greeting}}' })
      expect(result[:unused]).to be_empty
      expect(result[:undeclared]).to be_empty
    end
  end
end
