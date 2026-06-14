DFHUD.ClientInventoryAdapters['ox_inventory'] = {
    hasItem = function(itemName)
        local ok, count = pcall(function()
            return exports.ox_inventory:Search('count', itemName)
        end)

        return ok and (tonumber(count) or 0) > 0
    end,
}

