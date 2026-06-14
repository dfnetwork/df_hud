DFHUD.ServerInventoryAdapters['core_inventory'] = {
    hasItem = function(source, itemName)
        local ok, hasItem = pcall(function()
            return exports['core_inventory']:hasItem(source, itemName, 1)
        end)

        return ok and hasItem == true
    end,
}

