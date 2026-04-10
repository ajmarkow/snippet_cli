# frozen_string_literal: true

module SnippetCli
  # Carries shared wizard configuration: which file to save to and
  # which global var names are already declared in that file.
  # Passed explicitly rather than communicated via instance variables.
  WizardContext = Data.define(:global_var_names, :save_path) do
    def initialize(global_var_names: [], save_path: nil)
      super
    end
  end
end
