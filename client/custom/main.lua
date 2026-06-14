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

    return type(hooks.custom) == 'table' and hooks.custom or nil
end

function adapter:boot()
    return true
end

function adapter:getPlayerData()
    local hooks = getHooks()
    local playerData, handled = callHook(hooks and hooks.clientGetPlayerData)
    if handled and type(playerData) == 'table' then
        return playerData
    end

    return LocalPlayer.state or {}
end

function adapter:isPlayerLoaded()
    local hooks = getHooks()
    local loaded, handled = callHook(hooks and hooks.clientIsPlayerLoaded)
    return handled and loaded == true or NetworkIsPlayerActive(PlayerId())
end

function adapter:updateNeeds(_, state)
    local hooks = getHooks()
    local needs, handled = callHook(hooks and hooks.clientGetNeeds)
    if not handled or type(needs) ~= 'table' then
        return
    end

    state.hunger = tonumber(needs.hunger) or state.hunger
    state.thirst = tonumber(needs.thirst) or state.thirst
end

function adapter:refreshNeeds(state)
    self:updateNeeds(nil, state)
end

function adapter:registerEvents(_)
end

DFHUD.ClientFrameworkAdapters.custom = adapter
