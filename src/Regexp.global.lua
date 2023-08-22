--[[
	* Copyright (c) Roblox Corporation. All rights reserved.
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]
local RegEx = require(script.Parent.RegEx)
type Array<T> = { [number]: T }

type RegExpExecArray = Array<string> & { index: number?, input: string?, n: number }

export type RegExp = {
    exec: (self: RegExp, input: string) -> RegExpExecArray | nil,
    test: (self: RegExp, input: string) -> boolean,
}

local RegExp = {}
local RegExpMetatable = {
    __index = RegExp,
    __tostring = function(self)
        return tostring(self._innerRegEx)
    end,
}

function RegExp:exec(str: string): RegExpExecArray | nil
    local match = self._innerRegEx:match(str)
    if not match then
        return nil
    end

    local index = match:span()
    local groups = match:grouparr()

    local matches = { groups[0] }
    for i = 1, groups.n do
        matches[i + 1] = groups[i]
    end
    matches.n = groups.n + 1
    matches.index = index
    matches.input = str
    return matches
end

function RegExp:test(str: string): boolean
    return self:exec(str) ~= nil
end

local function new(_self, pattern: RegExp | string, flags: string?)
    flags = flags or ""
    local innerRegEx = RegEx.new(pattern, flags)
    local object = {
        source = pattern,
        ignoreCase = (flags :: string):find("i") ~= nil,
        global = (flags :: string):find("g") ~= nil,
        multiline = (flags :: string):find("m") ~= nil,
        _innerRegEx = innerRegEx,
    }

    return setmetatable(object, RegExpMetatable)
end

-- FIXME: Capture this as a local variable before returning, else a luau bug
-- prevents __call from being understood: https://jira.rbx.com/browse/CLI-40294
local interface = setmetatable(RegExp, {
    __call = new,
})

return interface
