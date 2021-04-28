-- this limits the total number of regex tests that will be parsed
-- from the pcre2 test file.
local MAX = 100000

local function parseTestFile(file)
	local testCaseList = {}

	local start = file:find("^/")

	local count = 0
	while start ~= nil do
		count = count + 1

		local ending = file:find("/", start + 1)
		local regexSource = file:sub(start + 1, ending - 1)
		local endOfRegexSourceLine = file:find("\n", ending + 1)
		local flags = file:sub(ending + 1, endOfRegexSourceLine - 1)

		local nextLineStart = endOfRegexSourceLine + 1
		local nextLineEnd = file:find("\n", endOfRegexSourceLine + 1)
		local line = file:sub(nextLineStart, nextLineEnd - 1)

		local regexTests = {}
		local currentTest = nil

		while line ~= "" do
			local matchIndex, matchValue = line:match("^([%d ]%d+): ?(.*)$")
			if line == "No match" then
				currentTest.matches = nil
			elseif matchIndex ~= nil then
				assert(
					currentTest.matches,
					"error parsing regex " .. tostring(count) .. " tests: '" .. regexSource .. "'"
				)
				table.insert(currentTest.matches, {
					index = tonumber(matchIndex),
					match = matchValue,
				})
			else
				if currentTest ~= nil then
					table.insert(regexTests, currentTest)
				end
				currentTest = {
					input = line:match("^ *(.+)$"),
					matches = {},
				}
			end
			nextLineStart = nextLineEnd + 1
			nextLineEnd = file:find("\n", nextLineStart)
			line = file:sub(nextLineStart, nextLineEnd - 1)
		end

		if currentTest ~= nil then
			table.insert(regexTests, currentTest)
		end

		local regexInfo = {
			source = regexSource,
			flags = flags,
		}

		table.insert(testCaseList, {
			source = regexSource,
			flags = flags,
			tests = regexTests,
		})

		if regexInfo.source == nil then
			error("\n\nerror at count = " .. count .. "\n\n")
		end

		start = file:find("\n/", nextLineEnd)
		if start then
			start = start + 1
		end

		if count >= MAX then
			break
		end
	end

	return testCaseList
end

return parseTestFile
