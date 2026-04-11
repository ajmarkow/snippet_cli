# frozen_string_literal: true

require 'dry/cli'
require_relative '../new_workflow'

module SnippetCli
  module Commands
    class New < Dry::CLI::Command
      desc 'Interactive wizard to build an Espanso match entry (alias: n)'

      option :trigger,      aliases: ['-t'],  desc: 'Single trigger string'
      option :triggers,     aliases: ['-T'],  desc: 'Comma-separated list of triggers'
      option :regex,        aliases: ['-r'],  desc: 'Regex trigger pattern'
      option :replace,      aliases: ['-R'],  desc: 'Replacement text'
      option :file,         aliases: ['-f'],  desc: 'Espanso match file to check conflicts against'
      option :no_warn,      type: :boolean, default: false, aliases: ['-nw'],
                            desc: 'Skip conflict warning'
      option :save,         type: :boolean, default: false, aliases: ['-s'],
                            desc: 'Save snippet to Espanso match file'
      option :no_vars,      type: :boolean, default: false,
                            desc: 'Skip variable collection; still prompts for replacement type and advanced options'
      option :bare,         type: :boolean, default: false,
                            desc: 'Bare mode: trigger and plain replacement only, no variables or advanced options'

      def call(**opts)
        NewWorkflow.new.run(opts)
      end
    end
  end
end
