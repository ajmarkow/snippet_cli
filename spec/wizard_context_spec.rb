# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/wizard_context'

RSpec.describe SnippetCli::WizardContext do
  describe 'defaults' do
    subject(:ctx) { described_class.new }

    it 'sets global_var_names to []' do
      expect(ctx.global_var_names).to eq([])
    end

    it 'sets save_path to nil' do
      expect(ctx.save_path).to be_nil
    end

    it 'sets pipe_output to nil' do
      expect(ctx.pipe_output).to be_nil
    end
  end

  describe 'with explicit values' do
    it 'stores global_var_names' do
      ctx = described_class.new(global_var_names: %w[greeting name])
      expect(ctx.global_var_names).to eq(%w[greeting name])
    end

    it 'stores save_path' do
      ctx = described_class.new(save_path: '/path/to/match.yml')
      expect(ctx.save_path).to eq('/path/to/match.yml')
    end

    it 'stores pipe_output' do
      io = StringIO.new
      ctx = described_class.new(pipe_output: io)
      expect(ctx.pipe_output).to be(io)
    end
  end

  it 'is a value object (frozen)' do
    ctx = described_class.new
    expect(ctx).to be_frozen
  end
end
