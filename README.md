[![Build Status](https://travis-ci.org/stefano-m/lua-enum.svg?branch=master)](https://travis-ci.org/stefano-m/lua-enum) [![codecov](https://codecov.io/gh/stefano-m/lua-enum/branch/master/graph/badge.svg)](https://codecov.io/gh/stefano-m/lua-enum)

# Simulate Enums in Lua

This is a little module that simulates [enumerated
types](https://en.wikipedia.org/wiki/Enumerated_type) in Lua.

Its API is very similar to the [Python3 Enum
API](https://docs.python.org/3/library/enum.html), although much more limited.

## Example Usage

``` lua
enum = require("enum")

sizes = {"SMALL", "MEDIUM", "BIG"}
Size = enum.new("Size", sizes)
print(Size) -- "<enum 'Size'>"
print(Size.SMALL) -- "<Size.SMALL: 1>"
print(Size.SMALL.name) -- "SMALL"
print(Size.SMALL.value) -- 1
assert(Size.SMALL ~= Size.BIG) -- true
assert(Size.SMALL < Size.BIG) -- error "Unsupported operation"
assert(Size[1] == Size.SMALL) -- true
Size[5] -- error "Invalid enum member: 5"

-- Enums cannot be modified
Size.MINI -- error "Invalid enum: MINI"
assert(Size.BIG.something == nil) -- true
Size.MEDIUM.other = 1 -- error "Cannot set fields in enum value"

-- Keys cannot be reused
Color = enum.new("Color", {"RED", "RED"}) -- error "Attempted to reuse key: 'RED'"
```

# Installing

## Using "classic" nix

If you are on NixOS, you can install this package from
[nix-stefano-m-overlays](https://github.com/stefano-m/nix-stefano-m-nix-overlays).

## Using nix flakes

This package can be installed as a [nix
flake](https://nixos.wiki/wiki/Flakes). It provides packages for the various
versions of Lua shipped with nix as well as an
[overlay](https://nixos.wiki/wiki/Overlays) that adds the `enum` attribute to
the Lua package sets.

## Using Luarocks

This package is [published to Luarocks as
`enum`](http://luarocks.org/modules/stefano-m/enum) and can be installed using

```shell
luarocks install enum
```
