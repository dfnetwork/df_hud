DFHUD.ClientInventoryAdapters.custom = {
    hasItem = function(itemName, context)
        local hooks = Config.InventoryHooks
        local customHooks = type(hooks) == 'table' and hooks.custom or nil
        if customHooks and type(customHooks.clientHasItem) == 'function' then
            local ok, result = pcall(customHooks.clientHasItem, itemName, context)
            if ok then
                return result == true
            end
        end

        if context and type(context.callFrameworkHook) == 'function' then
            local result, handled = context.callFrameworkHook('clientHasItem', itemName)
            if handled then
                return result == true
            end
        end

        return false
    end
}
