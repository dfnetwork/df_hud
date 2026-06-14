DFHUD.ServerInventoryAdapters['ak47_inventory'] = {
    hasItem = function(source, itemName)
        local resourceName = DFHUD.isResourceStarted('ak47_inventory') and 'ak47_inventory' or 'ak47_qb_inventory'
        local ok, amount = pcall(function()
            return exports[resourceName]:GetAmount(source, itemName)
        end)

        return ok and (tonumber(amount) or 0) > 0
    end,
}

