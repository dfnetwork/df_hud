local adapter = {}

function adapter:boot()
    if not DFHUD.isResourceStarted('ND_Core') then
        return nil
    end

    return true
end

function adapter:getPlayerData()
    if not self:boot() then
        return {}
    end

    local ok, playerData = pcall(function()
        return exports['ND_Core']:getPlayer()
    end)

    return ok and type(playerData) == 'table' and playerData or {}
end

function adapter:isPlayerLoaded(playerData)
    return next(playerData or {}) ~= nil
end

function adapter:updateNeeds(playerData, state)
    local metadata = playerData and (playerData.metadata or playerData.status) or nil
    if type(metadata) ~= 'table' then
        return
    end

    state.hunger = tonumber(metadata.hunger) or state.hunger
    state.thirst = tonumber(metadata.thirst) or state.thirst
end

function adapter:refreshNeeds(state)
    self:updateNeeds(self:getPlayerData(), state)
end

function adapter:registerEvents(ctx)
    RegisterNetEvent('ND:characterLoaded', function(playerData)
        ctx.onLoaded(playerData)
    end)

    RegisterNetEvent('ND:characterUnloaded', function()
        ctx.onUnloaded()
    end)

    RegisterNetEvent('ND:updateCharacter', function(playerData)
        if type(playerData) ~= 'table' then
            return
        end

        ctx.onPlayerData(playerData)
    end)
end

DFHUD.ClientFrameworkAdapters.nd = adapter
