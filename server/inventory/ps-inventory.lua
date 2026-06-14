DFHUD.ServerInventoryAdapters['ps-inventory'] = {
    hasItem = function(source, itemName)
        local ok, hasItem = pcall(function()
            return exports['ps-inventory']:HasItem(source, itemName, 1)
        end)

        return ok and hasItem == true
    end,
}

