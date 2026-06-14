DFHUD.ServerInventoryAdapters['ox_inventory'] = {
    hasItem = function(source, itemName)
        local ok, count = pcall(function()
            return exports.ox_inventory:Search(source, 'count', itemName)
        end)

        return ok and (tonumber(count) or 0) > 0
    end,
}

