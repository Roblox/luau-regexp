return function()
	local RegExpModule = script.Parent.Parent
	local RegExp = require(RegExpModule)
	type RegExp = RegExp.RegExp

	local Packages = RegExpModule.Parent
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect

	-- deviation: since we can't have `nil` values in list-like
	-- tables, we have to return the total number of matches, so
	-- that we can know when to stop iteration
	it("returns the number of matches", function()
		local re: RegExp = RegExp("abc")
		local result = re:exec("abc")
		jestExpect(result.n).toEqual(1)
	end)

	it("returns the matches starting from index 1", function()
		local re: RegExp = RegExp("abc")
		local result = re:exec("abc")
		jestExpect(result[1]).toEqual("abc")
	end)

	it("returns the starting position of the match", function()
		local re: RegExp = RegExp("abc")
		local result = re:exec("aabc")
		jestExpect(result.index).toEqual(2)
	end)
end
