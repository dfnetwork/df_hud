local adapter = {}

function adapter:boot()
    return true
end

function adapter:getPlayerData()
    return LocalPlayer.state or {}
end

function adapter:isPlayerLoaded()
    return NetworkIsPlayerActive(PlayerId())
end

function adapter:updateNeeds(_, _)
end

function adapter:refreshNeeds(state, ctx)
    if ctx and ctx.refreshNeedsFromServer then
        ctx.refreshNeedsFromServer(state)
    end
end

function adapter:registerEvents(ctx)
    RegisterNetEvent('mythic-characters:client:Spawned', function()
        ctx.onLoaded()
    end)
end

DFHUD.ClientFrameworkAdapters.mythic = adapter

