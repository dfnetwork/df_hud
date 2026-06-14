DFHUD.ClientInventoryAdapters['origen_inventory'] = {
    hasItem = function(itemName)
        local ok, hasItem = pcall(function()
            return exports.origen_inventory:hasItem(itemName)
        end)

        return ok and hasItem == true
    end,
}

