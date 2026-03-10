{ lib
}:

let
  this = lib.makeScope lib.callPackageWith makeThisScope;
  makeThisScope = this: {

    systemAttrs =
      ["packages" "legacyPackages" "devShells" "defaultPackage" "formatter"
        "apps" "checks"];

    unspecifiedSystem = builtins.concatStringsSep " " [
      "(unspecified-system). Cannot access this system-specific attribute"
      "from a non-system-specific context."
    ];

    narrowFlakeInput = system: inputName: input:
      if input._type or "" == "flake" then
        { original = input; }
        //
        (builtins.mapAttrs
          (k: v:
            if builtins.elem k this.systemAttrs
              then if v ? ${system}
                then v.${system}
                else "Input attribute does not exist: ${inputName}.${k}.${system}"
              else
                v)
          input)
      else
        input;

    narrowFlakeInputs = system: inputs:
      builtins.mapAttrs (this.narrowFlakeInput system) inputs;

    flake-for-all-systems =
      { ... }@args:
      { systems, outputs }@flake:
      let
        systems' = [ this.unspecifiedSystem ] ++ systems;

        systemSelfArgs = lib.genAttrs systems' (system:
          let args' = this.narrowFlakeInputs system args;
          in { system = system; } // args'
        );

        # map: system -> output set
        systemOutputs = lib.genAttrs systems' (system:
          outputs (systemSelfArgs.${system})
        );

        allOutputFields =
          builtins.attrNames (lib.mergeAttrsList (builtins.attrValues systemOutputs));

        partitionedOutputAttrs =
          builtins.partition (k: builtins.elem k this.systemAttrs) allOutputFields;
      in
        flake
        //
        lib.genAttrs partitionedOutputAttrs.wrong
          (attr: systemOutputs.${this.unspecifiedSystem}.${attr})
        //
        lib.genAttrs partitionedOutputAttrs.right
          (attr:
            let
              systems' = builtins.filter (s: systemOutputs ? ${s}.${attr}) systems;
            in
              lib.genAttrs systems' (sys: systemOutputs.${sys}.${attr}));
  };
in
  this
