{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let
      flakePkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlay ];
      };

      buildPackage = pname: luaPackages: with luaPackages;
        buildLuaPackage rec {
          name = "${pname}-${version}";
          inherit pname;
          # FIXME: add a Makefile or something so that 'make release' generates
          # the version, adds a tag and commits. Then we can read the version
          # with builtins.reafFile (beware of newlines!)
          version = "v0.1.1-${self.shortRev or "dev"}";

          src = ./.;

          propagatedBuildInputs = [ lua ];

          buildInputs = [ busted luacov luacheck ldoc ];

          buildPhase = ":";

          installPhase = ''
            mkdir -p "$out/share/lua/${lua.luaversion}"
            cp -r src/${pname} "$out/share/lua/${lua.luaversion}/"
          '';

          doCheck = true;
          checkPhase = ''
            luacheck src tests
            busted .
        '';

        };

    in
    {
      checks.x86_64-linux = self.packages.x86_64-linux;

      packages.x86_64-linux = {
        lua_enum = buildPackage "enum" flakePkgs.luaPackages;
        lua51_enum = buildPackage "enum" flakePkgs.lua51Packages;
        lua52_enum = buildPackage "enum" flakePkgs.lua52Packages;
        lua53_enum = buildPackage "enum" flakePkgs.lua53Packages;
        luajit_enum = buildPackage "enum" flakePkgs.luajitPackages;
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.lua_enum;

      devShell.x86_64-linux = flakePkgs.mkShell {
        LUA_PATH = "./src/?.lua;./src/?/init.lua";
        buildInputs = (with self.defaultPackage.x86_64-linux; buildInputs ++ propagatedBuildInputs) ++ (with flakePkgs; [
          nixpkgs-fmt
        ]);
      };

      overlay = final: prev: with self.packages.x86_64-linux; {
        lua = prev.lua.override {
          packageOverrides = this: other: {
            enum = lua_enum;
          };
        };

        lua5_1 = prev.lua5_1.override {
          packageOverrides = this: other: {
            enum = lua52_enum;
          };
        };

        lua5_2 = prev.lua5_2.override {
          packageOverrides = this: other: {
            enum = lua52_enum;
          };
        };

        lua5_3 = prev.lua5_3.override {
          packageOverrides = this: other: {
            enum = lua53_enum;
          };
        };

        luajit = prev.luajit.override {
          packageOverrides = this: other: {
            enum = luajit_enum;
          };
        };
      };


    };
}
