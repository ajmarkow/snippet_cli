# frozen_string_literal: true

module SnippetCli
  # Carries shared wizard configuration: which file to save to,
  # which global var names are already declared in that file,
  # and the pipe IO for structured output when stdout is redirected.
  # Passed explicitly rather than communicated via global state.
  WizardContext = Data.define(:global_var_names, :save_path, :pipe_output) do
    def initialize(global_var_names: [], save_path: nil, pipe_output: nil)
      super
    end
  end
end
