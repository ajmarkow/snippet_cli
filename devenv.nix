{ pkgs, ... }:

{
  languages.ruby = {
    enable = true;
    package = pkgs.ruby_4_0;
    bundler.enable = true;
  };

  git-hooks.hooks = {
    # Runs first (b < c < r alphabetically): security audit, no per-file args
    bundler-audit = {
      enable = true;
      name = "bundler audit";
      entry = "bundle exec bundler-audit check --update";
      language = "system";
      pass_filenames = false;
    };

    # Runs second: fast syntax check before rubocop
    check-ruby-syntax = {
      enable = true;
      name = "ruby syntax check";
      entry = "ruby -c";
      language = "system";
      types = [ "ruby" ];
      excludes = [ "^\\.devenv/" "^vendor/" ];
    };

    # Runs third: style/lint after syntax passes
    rubocop = {
      enable = true;
      entry = "bundle exec rubocop";
      language = "system";
      types = [ "ruby" ];
      excludes = [ "^\\.devenv/" "^vendor/" ];
    };
  };

  tasks = {
    "snippet_cli:test" = {
      exec = "bundle exec rake spec";
      description = "Run RSpec tests via rake";
    };
  };
}
