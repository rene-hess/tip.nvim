---@diagnostic disable: undefined-field

local parse = require("tip.show")._parse
local eq = assert.are.same

describe("tip.show - parse", function()
  it("parse an empty string", function()
    eq({
      {
        title = "",
        body = { "" },
      },
    }, parse(""))
  end)

  it("parse single tip", function()
    local input = [[
# This is the header
This is a tip]]
    eq({
      {
        title = "# This is the header",
        body = { "This is a tip" },
      },
    }, parse(input))
  end)

  it("parse multiple tips", function()
    local input = [[
# Header 1
Tip 1

# Header 2
Tip 2
]]
    eq({
      {
        title = "# Header 1",
        body = { "Tip 1", "" },
      },
      {
        title = "# Header 2",
        body = { "Tip 2", "" },
      },
    }, parse(input))
  end)
end)
