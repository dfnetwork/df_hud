DFHUD.ServerInventoryAdapters['mythic-inventory'] = {
    hasItem = function(source, itemName, ctx)
        local frameworkAdapter = ctx and ctx.getFrameworkAdapter and ctx.getFrameworkAdapter() or nil
        local inventory = frameworkAdapter and frameworkAdapter.getInventoryComponent and frameworkAdapter:getInventoryComponent() or nil
        if not inventory or not inventory.Items or not inventory.Items.Has then
            return false
        end

        local ok, hasItem = pcall(function()
            return inventory.Items:Has(source, itemName, 1)
        end)

        return ok and hasItem == true
    end,
}

