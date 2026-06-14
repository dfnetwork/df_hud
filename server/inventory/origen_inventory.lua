DFHUD.ServerInventoryAdapters['origen_inventory'] = {
    hasItem = function(source, itemName)
        local ok, hasItem = pcall(function()
            return exports.origen_inventory:HasItem(source, itemName, 1)
        end)

        return ok and hasItem == true
    end,
}

