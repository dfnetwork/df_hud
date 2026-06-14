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

function adapter:getPlayerData()
    QBCore = QBCore or self:boot()
    if not QBCore or not QBCore.Functions or not QBCore.Functions.GetPlayerData then
        return {}
    end

    local ok, playerData = pcall(function()
        return QBCore.Functions.GetPlayerData()
    end)

    return ok and type(playerData) == 'table' and playerData or {}
end

function adapter:isPlayerLoaded(playerData)
    return playerData.citizenid ~= nil or LocalPlayer.state.isLoggedIn == true
end

function adapter:updateNeeds(playerData, state)
    local metadata = playerData and playerData.metadata or nil
    if type(metadata) ~= 'table' then
        return
    end

    state.hunger = tonumber(metadata.hunger) or state.hunger
    state.thirst = tonumber(metadata.thirst) or state.thirst
end

function adapter:registerEvents(ctx)
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        self:boot()
        ctx.onLoaded(self:getPlayerData())
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        ctx.onUnloaded()
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
        if type(playerData) ~= 'table' then
            return
        end

        ctx.onPlayerData(playerData)
    end)
end

DFHUD.ClientFrameworkAdapters.qbcore = adapter

