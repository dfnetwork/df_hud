DFHUD.ClientInventoryAdapters['vrp'] = {
    hasItem = function(itemName, ctx)
        if not ctx or type(ctx.callFrameworkHook) ~= 'function' then
            return false
        end

        local hasItem, handled = ctx.callFrameworkHook('clientHasItem', itemName)
        return handled and hasItem == true or false
    end,
}

