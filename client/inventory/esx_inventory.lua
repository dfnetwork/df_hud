DFHUD.ClientInventoryAdapters['esx_inventory'] = {
    hasItem = function(itemName, ctx)
        local playerData = ctx and ctx.getPlayerData and ctx.getPlayerData() or {}
        local inventoryData = playerData and playerData.inventory or nil
        return DFHUD.getInventoryItemCount(inventoryData, itemName) > 0
    end,
}

DFHUD.ClientInventoryAdapters['esx_inventoryhud'] = DFHUD.ClientInventoryAdapters['esx_inventory']

