local adapter = {}

local function loadMythicComponent(name)
    if not DFHUD.isResourceStarted('mythic-base') then
        return nil
    end

    local ok, component = pcall(function()
        return exports['mythic-base']:FetchComponent(name)
    end)

    return ok and component or nil
end

function adapter:boot()
    return true
end

function adapter:getNeeds(source)
    local fetch = loadMythicComponent('Fetch')
    if not fetch or not fetch.Source then
        return {}
    end

    local ok, player = pcall(function()
        return fetch:Source(source)
    end)

    if not ok or not player or not player.GetData then
        return {}
    end

    local character = player:GetData('Character')
    if not character or not character.GetData then
        return {}
    end

    local metaData = character:GetData('MetaData') or character:GetData('Metadata') or {}
    return {
        hunger = tonumber(metaData.hunger),
        thirst = tonumber(metaData.thirst),
    }
end

function adapter:getInventoryComponent()
    local inventory = loadMythicComponent('Inventory')
    return inventory
end

DFHUD.ServerFrameworkAdapters.mythic = adapter

