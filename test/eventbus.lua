local M = {}

function M.new()
    local bus = {}
	
	bus.on = function (event, handler, index)
	end
	
	bus.off = function (event, handler)
	end
	
    bus.emit = function (event, ...)
    end
	
	return bus
end

return M
