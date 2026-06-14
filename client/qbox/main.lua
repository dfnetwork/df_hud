local adapter = {}

function adapter:boot()
    return true
end

function adapter:getPlayerData()
    return LocalPlayer.state or {}
end

function adapter:isPlayerLoaded()
    return LocalPlayer.state.isLoggedIn == true
end

function adapter:updateNeeds(_, _)
end

function adapter:registerEvents(ctx)
    RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
        ctx.onUnloaded()
    end)
end

DFHUD.ClientFrameworkAdapters.qbx = adapter

