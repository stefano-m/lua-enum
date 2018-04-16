-- Works with the 'busted' framework.
-- http://olivinelabs.com/busted/
require("busted")
local enum = require("enum")

describe("Enums", function ()

           it("have sensible string representation", function ()
                local Color = enum.new("Color", {"RED", "GREEN", "BLUE"})
                assert.equals("<enum 'Color'>", tostring(Color))
                assert.equals("<Color.RED: 1>", tostring(Color.RED))
                assert.equals("<Color.GREEN: 2>", tostring(Color.GREEN))
                assert.equals("<Color.BLUE: 3>", tostring(Color.BLUE))

                assert.equals("<Color.RED: 1>", tostring(Color[1]))
                assert.equals("<Color.GREEN: 2>", tostring(Color[2]))
                assert.equals("<Color.BLUE: 3>", tostring(Color[3]))
           end)

           it("cannot reuse the same key", function ()
                assert.has_error(
                  function ()
                    local _ = enum.new("Color", {"RED", "RED"})
                  end,
                  "Attempted to reuse key: 'RED'"
                )
           end)

           it("can be indexed by value", function ()
                local Color = enum.new("Color", {"RED", "GREEN", "BLUE"})

                assert.same(Color[1], Color.RED)
                assert.same(Color[2], Color.BLUE)
                assert.same(Color[3], Color.GREEN)

           end)

           it("error when created with other than strings", function ()
                assert.has_error(
                  function ()
                    local _ = enum.new('Wrong', {1, 2, 3})
                  end,
                  "Can create enum only from strings")
           end)

           it("error when getting the wrong enum value", function ()
                local Flavor = enum.new("Flavor", {"CHOCOLATE"})
                assert.has_error(
                  function ()
                    local _ = Flavor.VANILLA
                  end,
                  "Invalid enum member: VANILLA")

                assert.has_error(
                  function ()
                    local _ = Flavor[5]
                  end,
                  "Invalid enum member: 5")

           end)

           it("error when trying to set new enum values", function ()
                local Size = enum.new("Size", {"BIG"})
                assert.has_error(
                  function ()
                    Size.MEDIUM = 1
                  end,
                  "Cannot set enum value")
           end)

           it("have 'name' and 'value' fields", function ()
                local Size = enum.new("Size", {"SMALL", "BIG"})

                assert.equals("SMALL", Size.SMALL.name)
                assert.equals(1, Size.SMALL.value)
                assert.equals("BIG", Size.BIG.name)
                assert.equals(2, Size.BIG.value)
           end)

           it("error when trying to set a field", function ()
                local Size = enum.new("Size", {"BIG"})
                assert.has_error(
                  function ()
                    Size.BIG.name = "does not work"
                  end,
                  "Cannot set fields in enum value")
           end)

           it("have nil non-existent fields", function ()
                local Size = enum.new("Size", {"BIG"})
                assert.is_nil(Size.BIG.foot)
           end)

           it("are not ordered", function ()
                local Size = enum.new("Size", {"SMALL", "BIG"})
                assert.has_error(
                  function ()
                    local _ = Size.SMALL < Size.BIG
                  end,
                  "Unsupported operation")

                assert.has_error(
                  function ()
                    local _ = Size.SMALL >= Size.BIG
                  end,
                  "Unsupported operation")
           end)

           it("have the equality operator", function ()
                local Thing = enum.new("Thing", {"THING", "OTHER"})
                local Other = enum.new("Other", {"OTHER"})

                assert.not_equal(Thing.OTHER, Other.OTHER)
                assert.not_equal(Thing.THING, "a string")
                assert.not_equal(Thing.THING, Thing.OTHER)
           end)

end)
