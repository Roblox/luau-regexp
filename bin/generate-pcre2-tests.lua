local parseTestFile = require("bin.parseTestFile")

--[[
	The next require refers to a prce2 test data file wrapped as a lua module
	that returns a string. Tthese test data files can be found on github:
	https://github.com/luvit/pcre2/tree/master/testdata

	Each file that starts with `testoutput` should work, simply take one and
	create a lua file that looks like this:
	```
	return [==========================[
		*** content of the test data file, after the comments (lines starting with #) ***
	]==========================]
	```

	Require the test data file from the project root path. If you put it in the
	root, it is simply the filename without the `.lua` extension.
]]
local testFile = require("src.RegEx.__tests__.testoutput1")

local testCases = parseTestFile(testFile)

local luaOutputLines = {}

local function writeLine(strFormat, ...)
	table.insert(luaOutputLines, "\t" .. strFormat:format(...))
end

local function findNotEscaped(str, char, startIndex)
	local foundIndex = str:find(char, startIndex, true)
	while foundIndex ~= nil do
		local escaped = false
		local currentChar = foundIndex - 1
		while str:sub(currentChar, currentChar) == "\\" do
			escaped = not escaped
			currentChar = currentChar - 1
			if currentChar == 0 then
				break
			end
		end
		if not escaped then
			return foundIndex
		end
		foundIndex = str:find(char, foundIndex + 1, true)
	end
	return nil
end

local function removeUnescapeBackslash(str)
	local index = 1
	index = findNotEscaped(str, "\\", index)
	while index ~= nil do
		if str:sub(index + 1, index + 1):match("[afnrt%d\\]") then
			index = findNotEscaped(str, "\\", index + 1)
		else
			str = str:sub(1, index) .. str:sub(index)
			index = findNotEscaped(str, "\\", index + 2)
		end
	end
	return str
end

local function quote(str)
	return ('"%s"'):format(
		str:gsub('"', '\\"'):gsub("\n", "\\n")
	)
end

local function processInput(str)
	str = str
		:gsub("\\e", "\\027")
		:gsub("\\%$", "$")
		:gsub("\\x%x%x?", function(match)
			local asciiIndex = tonumber(match:sub(3), 16)
			return ("\\%03d"):format(asciiIndex)
		end)

	return quote(removeUnescapeBackslash(str))
end

local function processMatch(str)
	str = str:gsub("\\e", "\\027")
		:gsub("\\[^tnrfax\\%d]", function(match)
			return "\\" .. match
		end)
		:gsub("\\x%x%x", function(match)
			local asciiIndex = tonumber(match:sub(3), 16)
			return ("\\%03d"):format(asciiIndex)
		end)
	return quote(removeUnescapeBackslash(str))
end

for i, case in ipairs(testCases) do
	local totalTestCases = #case.tests
	if totalTestCases > 0 then
		writeLine("{")

		writeLine("\tsource = [==[%s]==],", case.source)
		if case.flags and case.flags ~= "" then
			writeLine("\tflags = %q,", case.flags)
		end

		writeLine("\ttests = {")
		for _, test in ipairs(case.tests) do
			if test.matches then
				writeLine("\t\t{")
				writeLine("\t\t\tinput = %s,", processInput(test.input))
				if #test.matches == 1 then
					writeLine("\t\t\tmatches = {{ index = %d, match = %s }},",
						test.matches[1].index,
						processMatch(test.matches[1].match)
					)
				else
					writeLine("\t\t\tmatches = {")
					for _, match in ipairs(test.matches) do
						writeLine(
							"\t\t\t\t{ index = %d, match = %s },",
							match.index,
							processMatch(match.match)
						)
					end
					writeLine("\t\t\t}")
				end
				writeLine("\t\t},")
			else
				writeLine("\t\t{ input = %s },", processInput(test.input))
			end
		end
		writeLine("\t},")

		writeLine("},")
	else
		print(("no test case found for #%d: %s"):format(i, case.source))
	end
end

local file = io.open("testoutput1.gen.lua", "w+")
file:write("return {\n")

file:write(table.concat(luaOutputLines, "\n"))

file:write("\n}\n")

file:close()
