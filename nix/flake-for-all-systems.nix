{ lib
}:

{
  flake-for-all-systems =
    { ... }@args:
    { systems, outputs }@flake:
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
      flake
      //
      systemOutputs.${firstSystem}
      //
      lib.genAttrs (builtins.filter (k: allOutputFields ? ${k}) systemAttrs)
        (attr:
          let
            systems' = builtins.filter (s: systemOutputs ? ${s}.${attr}) systems;
          in
            lib.genAttrs systems' (sys: systemOutputs.${sys}.${attr}));
}
