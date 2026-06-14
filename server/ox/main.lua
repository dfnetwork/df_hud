local adapter = {}

function adapter:boot()
    return true
end

function adapter:getNeeds(source)
    local ok, player = pcall(function()
        return Ox and Ox.GetPlayer(source) or nil
    end)

    if not ok or not player or not player.getStatus then
        return {}
    end

    local hungerOk, hungerValue = pcall(function()
        return player:getStatus('hunger')
    end)
    local thirstOk, thirstValue = pcall(function()
        return player:getStatus('thirst')
    end)

    return {
        hunger = hungerOk and tonumber(hungerValue) or nil,
        thirst = thirstOk and tonumber(thirstValue) or nil,
    }
end

DFHUD.ServerFrameworkAdapters.ox = adapter

