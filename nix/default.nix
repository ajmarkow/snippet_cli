{ lib, bundlerApp, bundlerUpdateScript, gum, defaultGemConfig }:

let
  # The gum Ruby gem ships its binary inside a platform-specific subdirectory of
  # exe/. Since we install the source gem (not a native gem), we patch it at
  # build time to symlink the gum binary from pkgs.gum into the expected path.
  gemConfig = defaultGemConfig // {
    gum = _attrs: {
      postInstall = ''
        installPath=$(cat $out/nix-support/gem-meta/install-path)
        platform=$(ruby -e 'puts [:cpu, :os].map { |m| Gem::Platform.local.public_send(m) }.join("-")')
        mkdir -p "$installPath/exe/$platform"
        ln -s ${gum}/bin/gum "$installPath/exe/$platform/gum"
      '';
    };
  };
in
bundlerApp {
  pname = "snippet_cli";
  gemdir = ./.;
  exes = [ "snippet_cli" ];
  inherit gemConfig;

  passthru.updateScript = bundlerUpdateScript "snippet_cli";

  meta = with lib; {
    description = "Interactively build snippets for Espanso";
    homepage    = "https://github.com/ajmarkow/snippet_cli";
    license     = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "snippet_cli";
    platforms   = platforms.unix;
  };
}
