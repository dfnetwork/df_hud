DFHUD.ServerInventoryAdapters['qb-inventory'] = {
    hasItem = function(source, itemName, ctx)
        local ok, hasItem = pcall(function()
            return exports['qb-inventory']:HasItem(source, itemName, 1)
        end)

        if ok then
            return hasItem == true
        end

        local frameworkAdapter = ctx and ctx.getFrameworkAdapter and ctx.getFrameworkAdapter()
        local core = frameworkAdapter and frameworkAdapter.getCore and frameworkAdapter:getCore() or nil
        if core and core.Functions and core.Functions.GetPlayer then
            local player = core.Functions.GetPlayer(source)
            if player and player.Functions and player.Functions.GetItemByName then
                return player.Functions.GetItemByName(itemName) ~= nil
            end
        end

        return false
    end,
}

