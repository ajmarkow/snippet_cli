# frozen_string_literal: true

module SnippetCli
  module TableFormatter
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def self.render(rows, headers:)
      widths = headers.each_with_index.map { |h, i| [h.length, *rows.map { |r| r[i].to_s.length }].max }
      top     = "╭#{widths.map { |w| '─' * (w + 2) }.join('┬')}╮"
      heading = "│#{headers.each_with_index.map { |h, i| " #{h.ljust(widths[i])} " }.join('│')}│"
      divider = "├#{widths.map { |w| '─' * (w + 2) }.join('┼')}┤"
      body    = rows.map do |row|
        "│#{row.each_with_index.map { |cell, i| " #{cell.to_s.ljust(widths[i])} " }.join('│')}│"
      end
      bottom = "╰#{widths.map { |w| '─' * (w + 2) }.join('┴')}╯"
      ([top, heading, divider] + body + [bottom]).map { |line| "\e[97m#{line}\e[0m" }.join("\n")
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
