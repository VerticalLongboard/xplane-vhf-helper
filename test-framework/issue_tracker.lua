local IssueTracker
do
    IssueTracker = {}

    function IssueTracker:new()
        local newInstanceWithState = {components = {}}
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function IssueTracker:declareLinkedKnownIssue(newComponent, newDescription, blameStringList)
        local blamedComponents = {}
        for componentName, component in pairs(self.components) do
            for issueDescription, issue in pairs(component.issues) do
                for key, blameString in pairs(blameStringList) do
                    if (issueDescription:find(blameString) ~= nil) then
                        blamedComponents[componentName] = blamedComponents[componentName] or {}
                    end
                end
            end
        end

        local num = 0
        for _, _ in pairs(blamedComponents) do
            num = num + 1
        end

        local knownIssueString = nil
        if (num == 0) then
            local newOccurrenceLocation = self:_getOccurrenceLocation()
            knownIssueString = ("[91mNONE, and cannot blame anything in %s[0m."):format(newOccurrenceLocation)
        else
            knownIssueString = "None for now, known issue in "
            for blamedComponentName, _ in pairs(blamedComponents) do
                knownIssueString = knownIssueString .. blamedComponentName .. "/"
            end
            knownIssueString = knownIssueString:sub(1, -2)
        end

        local newKnownIssue = self:post(newComponent, newDescription, knownIssueString)
        newKnownIssue.isLinked = true
        newKnownIssue.blamedComponents = blamedComponents
    end

    function IssueTracker:_getOccurrenceLocation()
        local stackLevelAboveTrackIssue = 3
        local debugInfo = debug.getinfo(stackLevelAboveTrackIssue)
        local newOccurrenceLocation = debugInfo.source:sub(2, -1) .. ":" .. debugInfo.currentline
        return newOccurrenceLocation
    end

    function IssueTracker:post(newComponent, newDescription, newWorkaround)
        local newOccurrenceLocation = self:_getOccurrenceLocation()

        local existingIssue = self:_find(newComponent, newDescription, newWorkaround)
        if (existingIssue ~= nil) then
            existingIssue.numOccurrences = existingIssue.numOccurrences + 1
            existingIssue.occurrences[newOccurrenceLocation] =
                existingIssue.occurrences[newOccurrenceLocation] or {workaround = nil}

            if (newWorkaround ~= nil) then
                local newOcurrence = existingIssue.occurrences[newOccurrenceLocation]
                newOcurrence.workaround = newWorkaround
            end

            return existingIssue
        end

        self.components[newComponent] = self.components[newComponent] or {issues = {}}
        local component = self.components[newComponent]

        component.issues[newDescription] =
            component.issues[newDescription] or {isLinked = false, occurrences = {}, numOccurrences = 1}
        local newIssue = component.issues[newDescription]
        newIssue.occurrences[newOccurrenceLocation] = newIssue.occurrences[newOccurrenceLocation] or {workaround = nil}
        local newOcurrence = newIssue.occurrences[newOccurrenceLocation]

        if (newWorkaround ~= nil) then
            newOcurrence.workaround = newWorkaround
        end

        return newIssue
    end

    function IssueTracker:print()
        self:_log("[4mIssue Tracker: All manually highlighted issues in code:[0m")
        local num = 0
        local numUnique = 0
        self:post("Lua", "Lua does not support 'continue' statements", "Use deeply nested ifs instead.")
        self:post("Lua", "Lua does not support labels", "Stick to ifs until next Lua update")
        for componentName, component in pairs(self.components) do
            local componentWasPrinted = false
            for issueDescription, issue in pairs(component.issues) do
                if (not issue.isLinked) then
                    if (not componentWasPrinted) then
                        self:_log(("\n[4m%s[0m:"):format(componentName))
                        componentWasPrinted = true
                    end
                    self:_log(
                        ("[96m(%dx)[0m%s"):format(issue.numOccurrences, Globals.prefixAllLines(issueDescription, " "))
                    )
                    numUnique = numUnique + 1
                    num = num + issue.numOccurrences
                    for occurrenceLocation, occurrence in pairs(issue.occurrences) do
                        if (occurrence.workaround == nil) then
                            self:_log((" [94m%s[0m: [93mNo Workaround[0m"):format(occurrenceLocation))
                        else
                            self:_log(
                                (" [94m%s[0m: Workaround:%s"):format(
                                    occurrenceLocation,
                                    Globals.prefixAllLines(occurrence.workaround, " ")
                                )
                            )
                        end
                    end
                end
            end
        end
        self:_log(("\nFound total=%d unique=%d issues.\n"):format(num, numUnique))

        self:_log("[96m[4mIssue Tracker: All linked known issues:[0m")
        for componentName, component in pairs(self.components) do
            local componentWasPrinted = false

            for issueDescription, issue in pairs(component.issues) do
                if (issue.isLinked) then
                    if (not componentWasPrinted) then
                        self:_log(("\n[4m%s[0m:"):format(componentName))
                        componentWasPrinted = true
                    end
                    self:_log(("%s"):format(Globals.prefixAllLines(issueDescription, " ")))
                    for occurrenceLocation, occurrence in pairs(issue.occurrences) do
                        assert(occurrence.workaround)
                        self:_log(("  Workaround:%s"):format(Globals.prefixAllLines(occurrence.workaround, " ")))
                    end
                end
            end
        end

        self:_log("")
    end

    function IssueTracker:_find(component, description, workaround)
        assert(component)
        assert(description)
        local existingComponent = self.components[component]
        if (existingComponent == nil) then
            return nil
        end

        for issueDescription, issue in pairs(existingComponent.issues) do
            if (issueDescription:find(description) ~= nil or description:find(issueDescription)) then
                return issue
            end
        end

        return nil
    end

    function IssueTracker:_log(string)
        print(string)
    end
end
return IssueTracker
