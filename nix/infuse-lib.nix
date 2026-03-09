{ lib
, infuse-src
}:

let
  infuse = import (infuse-src + "/default.nix") {
    lib = lib;
    sugars = infuse.v1.default-sugars ++ lib.attrsToList {
      # add __attrs as an alias for the built-in __output transformer.
      __attrs = path: infusion: target:
        let
          path' = lib.init path;
          infusion' = lib.setAttrByPath (path' ++ ["__output"]) infusion;
          target' = lib.setAttrByPath path' target;
        in
          lib.getAttrFromPath path' (infuse.v1.infuse target' infusion');
    };
  };
in
{
  infuse = infuse.v1.infuse;
  infuse-with = lib.flip infuse.v1.infuse;
}

