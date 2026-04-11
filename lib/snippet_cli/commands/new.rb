# frozen_string_literal: true

require 'dry/cli'
require_relative '../new_workflow'

module SnippetCli
  module Commands
    class New < Dry::CLI::Command
      desc 'Interactive wizard to build an Espanso match entry (alias: n)'

      option :save,         type: :flag, default: false, aliases: ['-s'],
                            desc: 'Save snippet to Espanso match file'
      option :no_vars,      type: :flag, default: false,
                            desc: 'Skip variable collection; still prompts for replacement type and advanced options'
      option :bare,         type: :flag, default: false,
                            desc: 'Bare mode: trigger and plain replacement only, no variables or advanced options'

      def call(**opts)
        NewWorkflow.new.run(opts)
      end
    end
  end
end
