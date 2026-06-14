local ESX = nil

local adapter = {}

local function normalizeEsxStatus(value)
    local numeric = tonumber(value)
    if not numeric then
        return nil
    end

    return math.max(0, math.min(100, math.floor((numeric / 1000000) * 100)))
end

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

function adapter:getPlayerData()
    ESX = ESX or self:boot()
    if not ESX or not ESX.GetPlayerData then
        return {}
    end

    local ok, playerData = pcall(function()
        return ESX.GetPlayerData()
    end)

    return ok and type(playerData) == 'table' and playerData or {}
end

function adapter:isPlayerLoaded()
    ESX = ESX or self:boot()
    if not ESX or not ESX.IsPlayerLoaded then
        return false
    end

    local ok, loaded = pcall(function()
        return ESX.IsPlayerLoaded()
    end)

    return ok and loaded == true or false
end

function adapter:updateNeeds(_, _)
end

function adapter:refreshNeeds(state)
    if not DFHUD.isResourceStarted('esx_status') then
        return
    end

    TriggerEvent('esx_status:getStatus', 'hunger', function(status)
        local normalized = status and normalizeEsxStatus(status.val)
        if normalized ~= nil then
            state.hunger = normalized
        end
    end)

    TriggerEvent('esx_status:getStatus', 'thirst', function(status)
        local normalized = status and normalizeEsxStatus(status.val)
        if normalized ~= nil then
            state.thirst = normalized
        end
    end)
end

function adapter:registerEvents(ctx)
    RegisterNetEvent('esx:playerLoaded', function(playerData)
        self:boot()
        ctx.onLoaded(playerData)
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        ctx.onUnloaded()
    end)
end

DFHUD.ClientFrameworkAdapters.esx = adapter

