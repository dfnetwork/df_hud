DFHUD.ServerInventoryAdapters['ND_Core'] = {
    hasItem = function(source, itemName, ctx)
        local frameworkAdapter = ctx and ctx.getFrameworkAdapter and ctx.getFrameworkAdapter() or nil
        local player = frameworkAdapter and frameworkAdapter.getPlayer and frameworkAdapter:getPlayer(source) or nil
        return player and DFHUD.getInventoryItemCount(player.inventory, itemName) > 0 or false
    end,
}

