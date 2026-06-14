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
    RegisterNetEvent('ox:playerLoaded', function()
        ctx.onLoaded()
    end)

    RegisterNetEvent('ox:startCharacterSelect', function()
        ctx.onUnloaded()
    end)
end

DFHUD.ClientFrameworkAdapters.ox = adapter

