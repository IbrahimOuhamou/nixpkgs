{ pkgs, lib }:

self: pkgs.haskell.packages.ghc810.override {
  overrides = self: super: with pkgs.haskell.lib.compose; with lib;
    let
      elmPkgs = rec {
        elmi-to-json = justStaticExecutables (overrideCabal
          (drv: {
            prePatch = ''
              substituteInPlace package.yaml --replace "- -Werror" ""
              hpack
            '';
            jailbreak = true;

            description = "Tool that reads .elmi files (Elm interface file) generated by the elm compiler";
            homepage = "https://github.com/stoeffel/elmi-to-json";
            license = licenses.bsd3;
            maintainers = [ maintainers.turbomack ];
          })
          (self.callPackage ./elmi-to-json { }));

        elm-instrument = justStaticExecutables (overrideCabal
          (drv: {
            prePatch = ''
              sed "s/desc <-.*/let desc = \"${drv.version}\"/g" Setup.hs --in-place
            '';
            jailbreak = true;
            # Tests are failing because of missing instances for Eq and Show type classes
            doCheck = false;

            description = "Instrument Elm code as a preprocessing step for elm-coverage";
            homepage = "https://github.com/zwilias/elm-instrument";
            license = licenses.bsd3;
            maintainers = [ maintainers.turbomack ];
          })
          (self.callPackage ./elm-instrument { }));
      };
    in
    elmPkgs // {
      inherit elmPkgs;

      # We need attoparsec < 0.14 to build elm for now
      attoparsec = self.attoparsec_0_13_2_5;

      # aeson 2.0.3.0 does not build with attoparsec_0_13_2_5
      aeson = doJailbreak self.aeson_1_5_6_0;

      # elm-instrument needs this
      indents = self.callPackage ./indents { };

      # elm-instrument's tests depend on an old version of elm-format, but we set doCheck to false for other reasons above
      elm-format = null;
    };
}
