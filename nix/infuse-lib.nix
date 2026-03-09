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

      __forAllSystems = _path: { systems, outputs }: { ... }@args:

        let
          systemAttrs =
            ["packages" "legacyPackages" "devShells" "defaultPackage" "formatter"
              "apps" "checks"];
          firstSystem = builtins.head systems;

          systemSelfArgs = lib.genAttrs systems (system:
            let
              # scopes all flake arguments to refer to the relevant system
              args' = builtins.mapAttrs (_: self:
                if self._type or "" == "flake" then
                  { original = self; }
                  // (builtins.mapAttrs
                    (k: v: if builtins.elem k systemAttrs then v.${system} else v)
                    self)
                else
                  self
              ) args;
            in
              { system = system; } // args'
          );

          # map: system -> output set
          systemOutputs = lib.genAttrs systems (system:
            outputs (systemSelfArgs.${system})
          );

          allOutputFields =
            lib.mergeAttrsList (builtins.attrValues systemOutputs);
        in
          systemOutputs.${firstSystem}
          //
          lib.genAttrs (builtins.filter (k: allOutputFields ? ${k}) systemAttrs)
            (attr:
              let
                systems' = builtins.filter (s: systemOutputs ? ${s}.${attr}) systems;
              in
                lib.genAttrs systems'
                  (sys: systemOutputs.${sys}.${attr}));
    };
  };
in
{
  infuse = infuse.v1.infuse;
  infuse-with = lib.flip infuse.v1.infuse;
}

