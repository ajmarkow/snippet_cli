# frozen_string_literal: true

module SnippetCli
  module TableFormatter
    def self.render(rows, headers:)
      widths = column_widths(rows, headers)
      lines = [
        border_line(widths, left: '╭', mid: '┬', right: '╮'),
        data_line(headers, widths),
        border_line(widths, left: '├', mid: '┼', right: '┤'),
        *rows.map { |row| data_line(row, widths) },
        border_line(widths, left: '╰', mid: '┴', right: '╯')
      ]
      lines.map { |line| colorize(line) }.join("\n")
    end

    def self.column_widths(rows, headers)
      headers.each_with_index.map { |h, i| [h.length, *rows.map { |r| r[i].to_s.length }].max }
    end
    private_class_method :column_widths

    def self.border_line(widths, left:, mid:, right:)
      "#{left}#{widths.map { |w| '─' * (w + 2) }.join(mid)}#{right}"
    end
    private_class_method :border_line

    def self.data_line(cells, widths)
      "│#{cells.each_with_index.map { |cell, i| " #{cell.to_s.ljust(widths[i])} " }.join('│')}│"
    end
    private_class_method :data_line

    def self.colorize(line)
      "\e[97m#{line}\e[0m"
    end
    private_class_method :colorize
  end
end
