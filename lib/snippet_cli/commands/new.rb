# frozen_string_literal: true

require 'dry/cli'
require_relative '../new_workflow'

module SnippetCli
  module Commands
    class New < Dry::CLI::Command
      desc 'Build an Espanso match entry interactively (alias: n)'

      option :save,         type: :flag, default: false, aliases: ['-s'],
                            desc: 'Save snippet to Espanso match file'
      option :no_vars,      type: :flag, default: false, aliases: ['-n'],
                            desc: 'Skip variables; supports alt types (image_path, markdown, html) and advanced options'
      option :bare,         type: :flag, default: false, aliases: ['-b'],
                            desc: 'Trigger(s) and plaintext only (single/multi-line); no vars, alt types, or advanced'

      def call(**opts)
        if opts[:bare] && opts[:no_vars]
          warn '--bare and --no-vars are mutually exclusive. Provide only one.'
          exit 1
        end
        NewWorkflow.new.run(opts)
      end
    end
  end
end
