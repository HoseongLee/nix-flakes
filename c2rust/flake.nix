{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, naersk }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;

      naersk' = pkgs.callPackage naersk { };

      libs = with pkgs; [
        cmake
        clang
        llvmPackages_latest.llvm
        llvmPackages_latest.libclang
      ];

      c2rust = naersk'.buildPackage {
        src = pkgs.fetchgit {
          url = "https://github.com/Medowhill/c2rust";
          branchName = "nopcrat";
          sha256 = "sha256-jKYbZlG8KKH1wdxIR+iECeFzndPrWxJNdLPPofvzDxQ=";
        };

        buildInputs = libs;

        cargoBuildOptions = l: l ++ [ "-Z" "sparse-registry" ];
        release = true;
      };

      tools = with pkgs; [
        rustc
        cargo
        rustfmt

        c2rust
      ];

    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system}.default = pkgs.mkShell rec {
        buildInputs = libs ++ tools;

        LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath libs}";
      };
    };
}
