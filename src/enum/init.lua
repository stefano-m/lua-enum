--[[
  Copyright 2017 - 2021 Stefano Mazzucco

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
]]

--[[-
  @module enum
  @release @VERSION@

  @author Stefano Mazzucco
  @copyright 2017 - 2021 Stefano Mazzucco
  @license Apache v2.0

  @usage
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
]]
local string = string

local enum = {}

local function make_meta(idx, name, value, type_)
  return {
        __index = { value = idx, name = value, _type = type_ },
        __newindex = function ()
          error("Cannot set fields in enum value", 2)
        end,
        __tostring = function ()
          return string.format('<%s.%s: %d>', name, value, idx)
        end,
        __le = function ()
          error("Unsupported operation")
        end,
        __lt = function ()
          error("Unsupported operation")
        end,
        __eq = function (this, other)
          return this._type == other._type and this.value == other.value
        end,
    }
end

local function check(values)
  local found = {}

  for _, v in ipairs(values) do
    if type(v) ~= "string" then
      error("Can create enum only from strings")
    end

    if found[v] == nil then
      found[v] = 1
    else
      found[v] = found[v] + 1
    end
  end

  local msg = "Attempted to reuse key: '%s'"
  for k, v in pairs(found) do
    if v > 1 then
      error(msg:format(k))
    end
  end

end

--- Make a new enum from all the string values passed in.
-- @string name the name of the enum
-- @tparam {string} values array of string values
-- @treturn table a read-only Enum table
function enum.new (name, values)

  local _Private = {}
  local _Type = {}

  setmetatable(
    _Private,
    {
      __index = function (t, k)
        local v = rawget(t, k)
        if v == nil then
          error("Invalid enum member: " .. k, 2)
        end
        return v
      end
    }
  )

  check(values)

  for i, v in ipairs(values) do
    local o = {}
    setmetatable(o, make_meta(i, name, v, _Type))
    _Private[v] = o
    _Private[i] = o
  end

  -- public readonly table
  local Enum = {}
  setmetatable(
    Enum,
    {
      __index = _Private,
      __newindex = function ()
        error("Cannot set enum value")
      end,
      __tostring = function ()
        return string.format("<enum '%s'>", name)
      end,
    }
  )

  return Enum
end

return enum
