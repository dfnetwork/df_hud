DFHUD.ServerInventoryAdapters['vrp'] = {
    hasItem = function(source, itemName, ctx)
        local frameworkAdapter = ctx and ctx.getFrameworkAdapter and ctx.getFrameworkAdapter() or nil
        if not frameworkAdapter or not frameworkAdapter.hasItem then
            return false
        end

        local hasItem, handled = frameworkAdapter:hasItem(source, itemName)
        return handled and hasItem == true or false
    end,
}

