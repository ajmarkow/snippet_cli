# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/var_builder/params'

RSpec.describe SnippetCli::VarBuilder::Params do
  describe '.validate!' do
    it 'does not raise for valid echo params' do
      expect { described_class.validate!('echo', { echo: 'hi' }) }.not_to raise_error
    end

    it 'does not raise for valid shell params' do
      expect { described_class.validate!('shell', { cmd: 'date', shell: 'bash' }) }.not_to raise_error
    end

    it 'does not raise for valid clipboard params (empty)' do
      expect { described_class.validate!('clipboard', {}) }.not_to raise_error
    end

    it 'raises InvalidParamsError when a required field is missing' do
      expect { described_class.validate!('echo', {}) }
        .to raise_error(SnippetCli::InvalidParamsError, /echo/)
    end

    it 'raises InvalidParamsError when an unknown field is present' do
      expect { described_class.validate!('echo', { echo: 'hi', bogus: 1 }) }
        .to raise_error(SnippetCli::InvalidParamsError)
    end

    it 'passes through for unknown var types (no schema = no constraint)' do
      expect { described_class.validate!('mystery', { anything: true }) }.not_to raise_error
    end
  end
end
