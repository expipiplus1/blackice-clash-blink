{ pkgs ? import <nixpkgs> {} }:

# Strip out the irrelevant parts of the source
let src = with pkgs.lib;
          let p = n: (toString ./dist) == n;
          in cleanSourceWith {filter = (n: t: !p n); src = cleanSource ./.;};

    clash-compiler = pkgs.fetchFromGitHub{
      owner  = "clash-lang";
      repo = "clash-compiler";
      rev  = "82c4d9d063e8390aaf12f3399a0755fc2ca7e60c";
      sha256 = "012xbycfvhj7qf596hx2p3jlwh5ysc3cm2iwdjh84kk3ijs9bfis";
      fetchSubmodules = true;
    };

    haskellPackages = with pkgs.haskell.lib; pkgs.haskell.packages.ghc822.override {
      overrides = self: super: {
        clash-prelude = dontCheck (self.callCabal2nix "clash-prelude" (clash-compiler + "/clash-prelude") {});
        clash-ghc = self.callCabal2nix "clash-ghc" (clash-compiler + "/clash-ghc") {};
        clash-lib = self.callCabal2nix "clash-lib" (clash-compiler + "/clash-lib") {};

        ghc-tcplugins-extra = self.callCabal2nix "ghc-tcplugins-extra" (pkgs.fetchFromGitHub{
          owner  = "clash-lang";
          repo = "ghc-tcplugins-extra";
          rev  = "4f2defb334da089100a16c8e75ba462b06c9d465";
          sha256 = "1f5c0pixg9vwsq6ym662f74f7pl8s4im4k3ndqgwd10zzkdx4ibr";
        }) {};
        ghc-typelits-extra = self.callCabal2nix "ghc-typelits-extra" (pkgs.fetchFromGitHub{
          owner  = "clash-lang";
          repo = "ghc-typelits-extra";
          rev  = "b9333c256151132eb97f72b262ddb23bd6a62446";
          sha256 = "0yliw6ds4m8z4f18nilazzxg71v04294kwrdqwl0jjxqizwxfnir";
        }) {};
        ghc-typelits-knownnat = self.callCabal2nix "ghc-typelits-knownnat" (pkgs.fetchFromGitHub{
          owner  = "clash-lang";
          repo = "ghc-typelits-knownnat";
          rev  = "9731ed3ae9c87a8930dd40eedced7c0128cb5e82";
          sha256 = "11pkxv1zkhf5yh173zi4m2rlr1gvrqqfzqaw0i5qs1wrp507dwyy";
        }) {};
        ghc-typelits-natnormalise = self.callCabal2nix "ghc-typelits-natnormalise" (pkgs.fetchFromGitHub{
          owner  = "clash-lang";
          repo = "ghc-typelits-natnormalise";
          rev  = "b4951d4d9b7307154eac0984530bf2d70bca3358";
          sha256 = "06y04gxs21h4pd0bl61flfc4jhzfkkhly5vcm6jkn7pcfxnwflk6";
        }) {};
        th-orphans = self.callCabal2nix "th-orphans" (pkgs.fetchFromGitHub{
          owner  = "mgsloan";
          repo = "th-orphans";
          rev  = "f30284acf132da465e70be17731201e4c61b7b94";
          sha256 = "19cw12v33c0wkd7bv4mjl7pgyswf52lkjk6mz82j4z31v0v2w60w";
        }) {};

        prettyprinter = self.callHackage "prettyprinter" "1.2.1" {};
      };
    };

  haskellBuildInputs = hp: with hp; [ clash-ghc ];
  ghcEnv = haskellPackages.ghcWithPackages haskellBuildInputs;
  ghcCommand = "ghc";
  ghcCommandCaps = pkgs.lib.toUpper ghcCommand;
  ghc = haskellPackages.ghc;

in

pkgs.stdenv.mkDerivation rec {
  name = "blink";
  inherit src;
  nativeBuildInputs = with pkgs;
    [ icestorm
      arachne-pnr
      yosys
      ghcEnv
    ];
  # LANG = "en_US.UTF-8";
  # LOCALE_ARCHIVE = lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
  shellHook = ''
    export NIX_${ghcCommandCaps}="${ghcEnv}/bin/${ghcCommand}"
    export NIX_${ghcCommandCaps}PKG="${ghcEnv}/bin/ghc-pkg"
    export NIX_${ghcCommandCaps}_DOCDIR="${ghcEnv}/share/doc/ghc/html"
    export NIX_${ghcCommandCaps}_LIBDIR="${ghcEnv}/lib/${ghcCommand}-${ghc.version}"
  '';
}