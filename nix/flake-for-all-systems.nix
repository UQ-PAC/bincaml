{ lib
}:

lib.makeScope lib.callPackageWith (this: {

  defaultPerSystemOutputs =
    ["packages" "legacyPackages" "devShells" "defaultPackage" "formatter"
      "apps" "checks"];

  unspecifiedSystem = builtins.concatStringsSep " " [
    "(unspecified-system). Cannot access this system-specific attribute"
    "from a non-system-specific context."
  ];

  inputForSystem' = systemAttrs: system: inputName: input:
    if input._type or "" == "flake" then
      { original = input; }
      //
      (builtins.mapAttrs
        (k: v:
          if builtins.elem k systemAttrs
            then if v ? ${system}
              then v.${system}
              else "Input attribute does not exist: ${inputName}.${k}.${system}"
            else
              v)
        input)
    else
      input;

  inputsForSystem = this.inputsForSystem' this.defaultPerSystemOutputs;

  inputsForSystem' = systemAttrs: system: inputs:
    builtins.mapAttrs (this.inputForSystem' systemAttrs system) inputs;

  flake-for-all-systems =
    { ... }@args:
    { systems, perSystem, perSystemOutputs ? this.defaultPerSystemOutputs , ... }@flake:
    let
      systems' = [ this.unspecifiedSystem ] ++ systems;

      systemSelfArgs = lib.genAttrs systems' (system:
        let args' = this.inputsForSystem' perSystemOutputs system args;
        in { system = system; } // args'
      );

      # map: system -> output set
      systemOutputs = lib.genAttrs systems' (system:
        perSystem (systemSelfArgs.${system})
      );

      allOutputFields =
        builtins.attrNames (lib.mergeAttrsList (builtins.attrValues systemOutputs));

      partitionedOutputAttrs =
        builtins.partition (k: builtins.elem k perSystemOutputs) allOutputFields;

      wrongJson = builtins.toJSON partitionedOutputAttrs.wrong;
      checkBadAttrs = lib.optionalAttrs (partitionedOutputAttrs.wrong != [])
        (throw ("Non-system-specific flake outputs ${wrongJson} are defined within 'perSystem'. "
          + "These outputs should be defined outside of 'perSystem'. Or, add ${wrongJson} "
          + "to 'perSystemOutputs' if it should be a system-specific output."));
    in
      checkBadAttrs
      //
      flake
      //
      lib.genAttrs partitionedOutputAttrs.right
        (attr:
          let
            systems' = builtins.filter (s: systemOutputs ? ${s}.${attr}) systems;
          in
            lib.genAttrs systems' (sys: systemOutputs.${sys}.${attr}));
})
