{ pkgs, ... }:

{
  languages.ruby = {
    enable = true;
    package = pkgs.ruby_4_0;
    bundler.enable = true;
  };

  tasks = {
    "snippet_cli:test" = {
      exec = "bundle exec rake spec";
      description = "Run RSpec tests via rake";
    };
  };
}
