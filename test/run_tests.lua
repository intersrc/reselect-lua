#!/usr/bin/env lua

require("src.reselect")
require("test.TestReselect")

local lu = require("test.luaunit")
local runner = lu.LuaUnit.new()
runner:setOutputType("text")
os.exit(runner:runSuite())
