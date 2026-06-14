DFHUD.ClientInventoryAdapters['qb-inventory'] = {
    hasItem = function(itemName)
        local ok, hasItem = pcall(function()
            return exports['qb-inventory']:HasItem(itemName)
        end)

        if ok then
            return hasItem == true
        end

        local fallbackOk, fallbackHasItem = pcall(function()
            return exports['qb-inventory']:HasItem(cache.serverId, itemName, 1)
        end)

        return fallbackOk and fallbackHasItem == true
    end,
}

