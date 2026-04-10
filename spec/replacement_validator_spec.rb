# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/replacement_validator'

class ReplacementValidatorHost
  include SnippetCli::WizardHelpers
  include SnippetCli::ReplacementValidator

  public :var_error_clear
end

RSpec.describe SnippetCli::ReplacementValidator do
  subject(:host) { ReplacementValidatorHost.new }

  let(:declared_var) { { name: 'greeting', type: 'echo', params: { echo: 'Hello' } } }
  let(:replacement_using_var) { { replace: 'Hi {{greeting}}' } }
  let(:replacement_missing_var) { { replace: 'Hi {{missing}}' } }

  describe '#var_error_clear' do
    context 'when vars and replacement are consistent' do
      it 'returns nil (no errors)' do
        result = host.var_error_clear([declared_var], replacement_using_var)
        expect(result).to be_nil
      end
    end

    context 'with explicit global_var_names: keyword' do
      it 'accepts global_var_names: and returns nil when no errors' do
        result = host.var_error_clear([declared_var], replacement_using_var, global_var_names: [])
        expect(result).to be_nil
      end

      it 'suppresses undeclared-var warning when var is in global_var_names' do
        replacement = { replace: 'Hi {{global_greeting}}' }
        result = host.var_error_clear([], replacement, global_var_names: ['global_greeting'])
        expect(result).to be_nil
      end
    end

    context 'when there are var usage warnings' do
      before { allow(SnippetCli::UI).to receive(:warning) }

      context 'and the user chooses to continue' do
        before do
          allow(Gum).to receive(:confirm)
            .with('Are you sure you want to continue?', prompt_style: anything).and_return(true)
        end

        it 'shows each warning via UI.warning' do
          host.var_error_clear([], replacement_missing_var)
          expect(SnippetCli::UI).to have_received(:warning).at_least(:once)
        end

        it 'returns nil to signal no retry needed' do
          result = host.var_error_clear([], replacement_missing_var)
          expect(result).to be_nil
        end
      end

      context 'and the user declines to continue' do
        before do
          allow(Gum).to receive(:confirm)
            .with('Are you sure you want to continue?', prompt_style: anything).and_return(false)
        end

        it 'returns a callable lambda' do
          result = host.var_error_clear([], replacement_missing_var)
          expect(result).to respond_to(:call)
        end
      end
    end
  end
end
