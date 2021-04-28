local ProcessService = game:GetService("ProcessService")
local Root = script.Parent.LuauRegExpTestModel

local Packages = Root.Packages
-- Load JestRoblox source into Packages folder so it's next to Roact as expected
local JestRoblox = require(Root.Packages.Dev.JestRoblox)

-- Run all tests, collect results, and report to stdout.
local result = JestRoblox.TestBootstrap:run(
	{ Packages.RegExp },
	JestRoblox.Reporters.TextReporterQuiet
)

if result.failureCount == 0 and #result.errors == 0 then
	ProcessService:ExitAsync(0)
else
	ProcessService:ExitAsync(1)
end
