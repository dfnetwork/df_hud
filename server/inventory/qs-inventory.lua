DFHUD.ServerInventoryAdapters['qs-inventory'] = {
    hasItem = function(source, itemName)
        local ok, hasItem = pcall(function()
            return exports['qs-inventory']:HasItem(source, itemName)
        end)

        return ok and hasItem == true
    end,
}

