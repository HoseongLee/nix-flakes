{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      connect = pkgs.writeScriptBin "connect" ''
        gio mount smb://192.168.0.1/hdd1
      '';

      sync-to = pkgs.writeScriptBin "sync-to" ''
        rsync -rvzP --no-p --delete --exclude={'.git','.github','.direnv','flake.*','**/*~','**/*.pyc','**/_build','**/_output','*.swp','.envrc'} . '/run/user/1000/gvfs/smb-share:server=192.168.0.1,share=hdd1/sync'
      '';

      sync-from = pkgs.writeScriptBin "sync-from" ''
        rsync -rvzP --no-p --exclude={'.git','.github','.direnv','flake.*','**/*~','**/*.pyc','**/_build','**/_output','*.swp','.envrc'} '/run/user/1000/gvfs/smb-share:server=192.168.0.1,share=hdd1/sync' .
      '';

      sync-tools = [
        connect
        sync-to
        sync-from
      ];

      pythonLib = with pkgs; [
        (python311.withPackages (ps: with ps; [six]))
      ];

      ocamlLib = with pkgs.ocaml-ng.ocamlPackages_5_0; [
        ocaml

        findlib
        mdx
        menhir

        ocaml-lsp
        ocamlformat
      ];

      ocamlBuildTools = with pkgs; [
        opam
        dune_3
        sphinx
      ];
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system}.default = pkgs.writeScriptBin "test-simd" ''
        ./watsup spec/wasm-3.0/*.watsup --animate --sideconditions --interpreter --test-interpreter simd 2> /dev/null
      '';

      devShells.${system}.default = pkgs.mkShell rec {
        buildInputs = sync-tools ++ pythonLib ++ ocamlLib ++ ocamlBuildTools;
      };
    };
}
