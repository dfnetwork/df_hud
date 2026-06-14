DFHUD.ClientInventoryAdapters['mythic-inventory'] = {
    hasItem = function(itemName, ctx)
        local playerData = ctx and ctx.getPlayerData and ctx.getPlayerData() or {}
        return (DFHUD.getInventoryItemCount(playerData.items, itemName) > 0)
            or (DFHUD.getInventoryItemCount(playerData.inventory, itemName) > 0)
    end,
}

