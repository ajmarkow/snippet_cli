# frozen_string_literal: true

require_relative 'version'

module SnippetCli
  INNER_WIDTH = 35

  def self.banner
    art = [
      '┏━┓┏┓╻╻┏━┓┏━┓┏━╸╺┳╸   ┏━╸╻  ╻',
      '┗━┓┃┗┫┃┣━┛┣━┛┣╸  ┃    ┃  ┃  ┃',
      '┗━┛╹ ╹╹╹  ╹  ┗━╸ ╹    ┗━╸┗━╸╹'
    ]

    top       = "╔#{'═' * INNER_WIDTH}╗"
    bottom    = "╚#{'═' * INNER_WIDTH}╝"
    art_lines = art.map { |l| "║  #{l.ljust(INNER_WIDTH - 2)}║" }

    [top, *art_lines, bottom, '', ''].join("\n")
  end
end
