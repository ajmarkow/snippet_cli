# frozen_string_literal: true

module SnippetCli
  # Applies Gum color overrides via environment variables.
  module GumTheme
    COLORS = {
      # gum confirm
      'GUM_CONFIRM_PROMPT_FOREGROUND' => '231',
      'GUM_CONFIRM_SELECTED_FOREGROUND' => '#F2D07C',
      'GUM_CONFIRM_SELECTED_BACKGROUND' => '#6B7A90',

      # gum choose — replaces default purple cursor (used for trigger type)
      'GUM_CHOOSE_CURSOR_FOREGROUND' => '#8CAAED',
      'GUM_CHOOSE_SELECTED_FOREGROUND' => '#A5D18A',
      'GUM_CHOOSE_HEADER_FOREGROUND' => '231',

      # gum filter — replaces default purple indicator and pink match highlight
      'GUM_FILTER_INDICATOR_FOREGROUND' => '#8CAAED',
      'GUM_FILTER_MATCH_FOREGROUND' => '#E88284',
      'GUM_FILTER_SELECTED_FOREGROUND' => '#A5D18A',
      'GUM_FILTER_PROMPT_FOREGROUND' => '#8CAAED',
      'GUM_FILTER_HEADER_FOREGROUND' => '231',

      # gum input — replaces default purple cursor
      'GUM_INPUT_CURSOR_FOREGROUND' => '#8CAAED',
      'GUM_INPUT_PROMPT_FOREGROUND' => '#8CAAED',
      'GUM_INPUT_HEADER_FOREGROUND' => '231',

      # gum write — replaces default purple cursor
      'GUM_WRITE_CURSOR_FOREGROUND' => '#8CAAED',
      'GUM_WRITE_PROMPT_FOREGROUND' => '#8CAAED',
      'GUM_WRITE_HEADER_FOREGROUND' => '231'
    }.freeze

    def self.apply!
      COLORS.each { |key, val| ENV[key] = val }
    end
  end
end
