--[[

MIT License

Copyright (c) 2020 VerticalLongboard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]
if (_VERSION == "Lua 5.4") then
    LOAD_LUA_STRING = function(str)
        return load(str)
    end
    TABLE_INSERT_TWO_ARGUMENTS = function(t, v)
        table.insert(t, #t + 1, v)
    end
elseif (_VERSION == "Lua 5.1") then
    LOAD_LUA_STRING = function(str)
        return loadstring(str)
    end
    TABLE_INSERT_TWO_ARGUMENTS = function(t, v)
        table.insert(t, v)
    end
else
    LOAD_LUA_STRING = function(str)
        return loadstring(str)
    end
    TABLE_INSERT_TWO_ARGUMENTS = function(t, v)
        table.insert(t, v)
    end
end

local M = {}
M.Time = {
    now = function()
        return os.clock()
    end
}

M.IO = {
    Constants = {
        Modes = {
            Overwrite = "w",
            Read = "r",
            Binary = "b"
        }
    }
}

M.IO.open = function(ioPath, mode)
    return io.open(ioPath, mode)
end

TRACK_ISSUE = TRACK_ISSUE or function(component, description, workaround)
    end

MULTILINE_TEXT = MULTILINE_TEXT or function(...)
    end

TRIGGER_ISSUE_AFTER_TIME = TRIGGER_ISSUE_AFTER_TIME or function(...)
    end

TRIGGER_ISSUE_IF = TRIGGER_ISSUE_IF or function(conditition)
    end

return M
