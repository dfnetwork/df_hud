DFHUD.ServerInventoryAdapters['esx_inventory'] = {
    hasItem = function(source, itemName, ctx)
        local frameworkAdapter = ctx and ctx.getFrameworkAdapter and ctx.getFrameworkAdapter() or nil
        local esx = frameworkAdapter and frameworkAdapter.getShared and frameworkAdapter:getShared() or nil
        if not esx then
            return false
        end

        local xPlayer = esx.Player and esx.Player(source) or (esx.GetPlayerFromId and esx.GetPlayerFromId(source))
        if not xPlayer then
            return false
        end

        if xPlayer.hasItem then
            local ok, hasItem = pcall(function()
                return xPlayer.hasItem(itemName)
            end)

            if ok then
                return hasItem == true
            end
        end

        if xPlayer.getInventoryItem then
            local ok, item = pcall(function()
                return xPlayer.getInventoryItem(itemName)
            end)

            if ok and type(item) == 'table' then
                return (tonumber(item.count or item.amount) or 0) > 0
            end
        end

        return false
    end,
}

DFHUD.ServerInventoryAdapters['esx_inventoryhud'] = DFHUD.ServerInventoryAdapters['esx_inventory']

