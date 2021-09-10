return function()
	local RegExpModule = script.Parent.Parent
	local RegExp = require(RegExpModule)
	type RegExp = RegExp.RegExp

	local Packages = RegExpModule.Parent
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect

	it("returns true when the regex matches", function()
		local re: RegExp = RegExp("a")
		jestExpect(re:test("a")).toEqual(true)
	end)

	it("returns false when the regex does not match", function()
		local re: RegExp = RegExp("a")
		jestExpect(re:test("b")).toEqual(false)
	end)
end
