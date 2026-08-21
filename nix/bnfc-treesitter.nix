{ lib
, haskell
, haskellPackages
, fetchFromGitHub
}:

lib.pipe haskellPackages.BNFC [
  (haskell.lib.compose.overrideSrc {
    src = fetchFromGitHub {
      owner = "BNFC";
      repo = "bnfc";
      rev = "2e4c906d99d904ba0a214ebd29ddfa95e5a74944";
      hash = "sha256-7XPTUmdmoWM22UHdDSQSkHP8op6OZSU1a/VGy0czo+0=";
    };
    version = "2.9.6.3-unstable-2026-05-08";
  })
  (haskell.lib.compose.overrideCabal (_: {
    prePatch = "cd source";
  }))
  haskell.lib.justStaticExecutables
  haskell.lib.compose.dontHaddock
  haskell.lib.compose.dontCheck
]
