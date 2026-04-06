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
      expect(warnings([echo_var], { replace: 'Hi {{greeting}}' })).to be_empty
    end
  end

  context 'when vars are properly used in html:' do
    it 'returns no warnings' do
      expect(warnings([echo_var], { html: '<b>{{greeting}}</b>' })).to be_empty
    end
  end

  context 'when vars are properly used in markdown:' do
    it 'returns no warnings' do
      expect(warnings([echo_var], { markdown: '**{{greeting}}**' })).to be_empty
    end
  end

  context 'when vars are properly used in image_path:' do
    it 'returns no warnings' do
      expect(warnings([echo_var], { image_path: '/imgs/{{greeting}}.png' })).to be_empty
    end
  end

  context 'when a declared var is unused' do
    it 'returns a warning mentioning the var name' do
      result = warnings([echo_var], { replace: 'Hello World' })
      expect(result).not_to be_empty
      expect(result.first).to include('greeting')
      expect(result.first).to match(/declared.*unused|unused.*declared/i)
    end

    it 'returns one warning per unused var' do
      result = warnings([echo_var, shell_var], { replace: 'static text' })
      expect(result.length).to eq(2)
    end
  end

  context 'when a var ref is used but not declared' do
    it 'returns a warning mentioning the var name' do
      result = warnings([], { replace: 'Hello {{ghost}}' })
      expect(result).not_to be_empty
      expect(result.first).to include('ghost')
      expect(result.first).to match(/not declared|undeclared/i)
    end

    it 'detects undeclared refs in html: field' do
      result = warnings([], { html: '<b>{{ghost}}</b>' })
      expect(result.first).to include('ghost')
    end

    it 'detects undeclared refs in markdown: field' do
      result = warnings([], { markdown: '**{{ghost}}**' })
      expect(result.first).to include('ghost')
    end

    it 'detects undeclared refs in image_path: field' do
      result = warnings([], { image_path: '/imgs/{{ghost}}.png' })
      expect(result.first).to include('ghost')
    end
  end

  context 'when there are no vars and no references' do
    it 'returns no warnings' do
      expect(warnings([], { replace: 'plain text' })).to be_empty
    end
  end

  context 'when vars array is empty' do
    it 'returns no warnings for plain replacement' do
      expect(warnings([], { replace: 'hello' })).to be_empty
    end
  end

  context 'with mixed declared/undeclared/unused' do
    it 'returns warnings only for problematic vars' do
      vars = [echo_var, shell_var]
      # greeting used ✓, user unused ✗, ghost undeclared ✗
      result = warnings(vars, { replace: 'Hi {{greeting}} and {{ghost}}' })
      expect(result).to match_array(
        [a_string_including('user'), a_string_including('ghost')]
      )
    end
  end

  context 'with global_var_names' do
    def warnings_with_globals(vars, replacement, global_var_names:)
      described_class.match_warnings(vars, replacement, global_var_names: global_var_names)
    end

    it 'suppresses undeclared warning when var is in global_var_names' do
      result = warnings_with_globals([], { replace: 'Today is {{dt}}' }, global_var_names: %w[dt])
      expect(result).to be_empty
    end

    it 'still warns for vars not in local or global' do
      result = warnings_with_globals([], { replace: '{{dt}} {{ghost}}' }, global_var_names: %w[dt])
      expect(result.length).to eq(1)
      expect(result.first).to include('ghost')
    end

    it 'does not suppress unused-local-var warnings' do
      result = warnings_with_globals([echo_var], { replace: 'Today is {{dt}}' }, global_var_names: %w[dt])
      expect(result.length).to eq(1)
      expect(result.first).to include('greeting')
      expect(result.first).to match(/unused/i)
    end

    it 'handles mix of local vars and global vars' do
      result = warnings_with_globals([echo_var], { replace: 'Hi {{greeting}} on {{dt}}' }, global_var_names: %w[dt])
      expect(result).to be_empty
    end
  end

  context 'with string-keyed var hashes (from YAML load)' do
    it 'handles string keys gracefully' do
      string_var = { 'name' => 'greeting', 'type' => 'echo', 'params' => { 'echo' => 'Hello' } }
      expect(warnings([string_var], { replace: 'Hi {{greeting}}' })).to be_empty
    end
  end
end
