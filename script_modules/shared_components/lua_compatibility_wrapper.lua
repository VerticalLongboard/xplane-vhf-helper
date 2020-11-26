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
end
