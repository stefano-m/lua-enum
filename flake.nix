{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }:
    let

      currentVersion = builtins.readFile ./VERSION;

      flakePkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };

      buildPackage = pname: luaPackages: with luaPackages;
        buildLuaPackage rec {
          name = "${pname}-${version}";
          inherit pname;
          version = "${currentVersion}-${self.shortRev or "dev"}";

          src = ./.;

          propagatedBuildInputs = [ lua ];

          buildInputs = [ busted luacov luacheck ldoc ];

          buildPhase = ":";

          installPhase = ''
            mkdir -p "$out/share/lua/${lua.luaversion}"
            cp -r src/${pname} "$out/share/lua/${lua.luaversion}/"
          '';

          doCheck = true;
          checkPhase = "make check";

        };

    in
    {
      checks.x86_64-linux = self.packages.x86_64-linux;

      packages.x86_64-linux = rec {
        default = lua_enum;
        lua_enum = buildPackage "enum" flakePkgs.luaPackages;
        lua51_enum = buildPackage "enum" flakePkgs.lua51Packages;
        lua52_enum = buildPackage "enum" flakePkgs.lua52Packages;
        lua53_enum = buildPackage "enum" flakePkgs.lua53Packages;
        luajit_enum = buildPackage "enum" flakePkgs.luajitPackages;
      };

      devShells.x86_64-linux.default = flakePkgs.mkShell {
        LUA_PATH = "./src/?.lua;./src/?/init.lua";
        buildInputs = (with self.packages.x86_64-linux.default; buildInputs ++ propagatedBuildInputs) ++ (with flakePkgs; [
          nixpkgs-fmt
          luarocks
        ]);
      };

      overlays.default = final: prev: with self.packages.x86_64-linux; {

        # NOTE: lua = prev.lua.override { packageOverrides = this: other: {... }}
        # Seems to be broken as it does not allow to combine different overlays.

        luaPackages = prev.luaPackages // {
          enum = lua_enum;
        };

        lua51Packages = prev.lua51Packages // {
          enum = lua51_enum;
        };

        lua52Packages = prev.lua52Packages // {
          enum = lua52_enum;
        };

        lua53Packages = prev.lua53Packages // {
          enum = lua53_enum;
        };

        luajitPackages = prev.luajitPackages // {
          enum = luajit_enum;
        };

      };


    };
}
