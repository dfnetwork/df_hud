local adapter = {}

local function callHook(hook, ...)
    if type(hook) ~= 'function' then
        return nil, false
    end

    local ok, result = pcall(hook, ...)
    if not ok then
        return nil, false
    end

    return result, true
end

local function getHooks()
    local hooks = Config.FrameworkHooks
    if type(hooks) ~= 'table' then
        return nil
    end

    return type(hooks.vrp) == 'table' and hooks.vrp or nil
end

function adapter:boot()
    return true
end

function adapter:getNeeds(source)
    local hooks = getHooks()
    local needs, handled = callHook(hooks and hooks.serverGetNeeds, source)
    return handled and type(needs) == 'table' and needs or {}
end

function adapter:hasItem(source, itemName)
    local hooks = getHooks()
    local hasItem, handled = callHook(hooks and hooks.serverHasItem, source, itemName)
    if handled then
        return hasItem == true, true
    end

    return false, false
end

DFHUD.ServerFrameworkAdapters.vrp = adapter

