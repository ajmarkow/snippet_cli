{ pkgs, ... }:

{
  languages.ruby = {
    enable = true;
    package = pkgs.ruby_4_0;
    bundler.enable = true;
  };
}
