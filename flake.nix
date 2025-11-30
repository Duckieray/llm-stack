{
  description = "Local LLM stack (Ollama + OpenWebUI) as a runnable Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
	
	llmStack = pkgs.writeShellApplication {
	  name = "llm-stack";
	  runtimeInputs = with pkgs; [
	    process-compose
            docker
            curl
            jq
            bash
	  ];
	  text = ''
	    set -euo pipefail
	    echo "=== Starting Local LLM Stack ==="
	    process-compose up
	  '';
	};

      in
      {
	
	# expose `nix run`
	apps.default = {
	  type = "app";
	  program = "${llmStack}/bin/llm-stack";
	};

	# expose installable package as: nix profile install github:user/repo
	packages.default = llmStack;

	# Provide a developer shell with docker + process-compose
	devShells.default = pkgs.mkShell {
	  buildInputs = with pkgs; [
	    docker
	    process-compose
	    curl
	    jq
	    bash
	  ];
	};
      }
    );
}
