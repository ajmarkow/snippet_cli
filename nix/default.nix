{ lib, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "snippet_cli";
  gemdir = ./.;
  exes = [ "snippet_cli" ];

  # The `gum` gem (0.3.2) ships the gum binary as a platform-specific native gem,
  # so no separate pkgs.gum in buildInputs is needed.

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
