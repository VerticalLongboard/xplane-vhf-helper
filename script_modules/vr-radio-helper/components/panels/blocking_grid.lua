local BlockingGrid
do
    BlockingGrid = {}

    function BlockingGrid:new(screenWidth, screenHeight)
        local newInstanceWithState = {}
        setmetatable(newInstanceWithState, self)
        self.__index = self

        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self:reset()
        return newInstanceWithState
    end

    function BlockingGrid:reset()
        self.len = 20
        if (self.grid == nil) then
            self.grid = {}
        end

        for y = 1, self.len do
            for x = 1, self.len do
                self.grid[y * self.len + x] = 0
            end
        end
    end

    function BlockingGrid:fill(gridPos)
        local i = gridPos[2] * self.len + gridPos[1]
        local v = self.grid[i]
        self.grid[i] = v + 1
    end

    function BlockingGrid:empty(gridPos)
        local i = gridPos[2] * self.len + gridPos[1]
        local v = self.grid[i]
        self.grid[i] = v - 1
    end

    function BlockingGrid:getValue(gridPos)
        return self.grid[gridPos[2] * self.len + gridPos[1]]
    end

    function BlockingGrid:map(screenPos)
        return {
            math.max(1, math.min(self.len, (math.floor((self.len * screenPos[1]) / self.screenWidth) + 1))),
            math.max(1, math.min(self.len, (math.floor((self.len * screenPos[2]) / self.screenHeight) + 1)))
        }
    end

    function BlockingGrid:emptyAtScreenPos(screenPos)
        self:empty(self:map(screenPos))
    end

    function BlockingGrid:fillAtScreenPos(screenPos)
        self:fill(self:map(screenPos))
    end
end
return BlockingGrid
