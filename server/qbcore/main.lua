local QBCore = nil

local adapter = {}

function adapter:boot()
    if not DFHUD.isResourceStarted('qb-core') then
        self.core = nil
        return nil
    end

    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if ok then
        QBCore = core
        self.core = core
        return core
    end

    return nil
end

function adapter:getNeeds(_)
    return {}
end

function adapter:getCore()
    return QBCore or self:boot()
end

DFHUD.ServerFrameworkAdapters.qbcore = adapter

