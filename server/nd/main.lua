local adapter = {}

function adapter:boot()
    if not DFHUD.isResourceStarted('ND_Core') then
        return nil
    end

    return true
end

function adapter:getPlayer(source)
    if not self:boot() then
        return nil
    end

    local ok, player = pcall(function()
        return exports['ND_Core']:getPlayer(source)
    end)

    return ok and type(player) == 'table' and player or nil
end

function adapter:getNeeds(source)
    local player = self:getPlayer(source)
    if not player then
        return {}
    end

    local metadata = player.metadata or player.status or {}
    return {
        hunger = tonumber(metadata.hunger),
        thirst = tonumber(metadata.thirst),
    }
end

DFHUD.ServerFrameworkAdapters.nd = adapter

