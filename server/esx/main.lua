local ESX = nil

local adapter = {}

function adapter:boot()
    if not DFHUD.isResourceStarted('es_extended') then
        self.shared = nil
        return nil
    end

    local ok, esx = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and esx then
        ESX = esx
        self.shared = esx
        return esx
    end

    local shared = nil
    TriggerEvent('esx:getSharedObject', function(obj)
        shared = obj
    end)

    ESX = shared
    self.shared = shared
    return shared
end

function adapter:getNeeds(_)
    return {}
end

function adapter:getShared()
    return ESX or self:boot()
end

DFHUD.ServerFrameworkAdapters.esx = adapter

