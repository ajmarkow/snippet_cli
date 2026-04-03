# frozen_string_literal: true

require 'gum'

module SnippetCli
  FIGLET_ART = "┏━┓┏┓╻╻┏━┓┏━┓┏━╸╺┳╸   ┏━╸╻  ╻\n" \
               "┗━┓┃┗┫┃┣━┛┣━┛┣╸  ┃    ┃  ┃  ┃\n" \
               '┗━┛╹ ╹╹╹  ╹  ┗━╸ ╹    ┗━╸┗━╸╹'

  def self.banner
    Gum::Command.run_non_interactive(
      'style', '--border=rounded', '--padding=1 2', '--align=center', '--border-foreground=075',
      input: FIGLET_ART
    )
  end
end
