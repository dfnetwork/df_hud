DFHUD.ServerInventoryAdapters.custom = {
    hasItem = function(source, itemName, context)
        local hooks = Config.InventoryHooks
        local customHooks = type(hooks) == 'table' and hooks.custom or nil
        if customHooks and type(customHooks.serverHasItem) == 'function' then
            local ok, result = pcall(customHooks.serverHasItem, source, itemName, context)
            if ok then
                return result == true
            end
        end

        local frameworkAdapter = context and context.getFrameworkAdapter and context.getFrameworkAdapter() or nil
        if frameworkAdapter and frameworkAdapter.hasItem then
            local result, handled = frameworkAdapter:hasItem(source, itemName)
            if handled then
                return result == true
            end
        end

        return false
    end
}
