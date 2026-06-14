DFHUD.ClientInventoryAdapters['ND_Core'] = {
    hasItem = function(itemName, ctx)
        local playerData = ctx and ctx.getPlayerData and ctx.getPlayerData() or {}
        return DFHUD.getInventoryItemCount(playerData.inventory, itemName) > 0
    end,
}

