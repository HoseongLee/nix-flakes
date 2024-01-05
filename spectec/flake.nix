{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

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
        buildInputs = pythonLib ++ ocamlLib ++ ocamlBuildTools;
      };
    };
}
