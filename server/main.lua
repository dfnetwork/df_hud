local QBCore = nil
local framework = nil
local inventory = nil
local manualGearsPreferences = {}
local MANUAL_GEARS_PREFS_FILE = 'data/manual_gears_prefs.json'

local function loadManualGearsPreferences()
    local raw = LoadResourceFile(GetCurrentResourceName(), MANUAL_GEARS_PREFS_FILE)
    if not raw or raw == '' then
        manualGearsPreferences = {}
        return
    end

    local decoded = json.decode(raw)
    manualGearsPreferences = type(decoded) == 'table' and decoded or {}
end

local function saveManualGearsPreferences()
    SaveResourceFile(GetCurrentResourceName(), MANUAL_GEARS_PREFS_FILE, json.encode(manualGearsPreferences), -1)
end

local function getPlayerPreferenceKey(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:find('license:', 1, true) == 1 then
            return identifier
        end
    end

    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:find('fivem:', 1, true) == 1 then
            return identifier
        end
    end

    return ('source:%s'):format(source)
end

local function getManualGearsPreference(source)
    local key = getPlayerPreferenceKey(source)
    local saved = manualGearsPreferences[key]

    if type(saved) == 'boolean' then
        return saved
    end

    return Config.ManualGears.defaultEnabled == true
end

local function setManualGearsPreference(source, enabled)
    local key = getPlayerPreferenceKey(source)
    manualGearsPreferences[key] = enabled == true
    saveManualGearsPreferences()
end

local function isResourceStarted(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started' or state == 'starting'
end

local function resolveFramework()
    if Config.Framework == 'qbx' and isResourceStarted('qbx_core') then
        return 'qbx'
    end

    if Config.Framework == 'qbcore' and isResourceStarted('qb-core') then
        return 'qbcore'
    end

    if isResourceStarted('qbx_core') then
        return 'qbx'
    end

    if isResourceStarted('qb-core') then
        return 'qbcore'
    end

    return nil
end

local function resolveInventory()
    if Config.Minimap.inventory ~= 'auto' and isResourceStarted(Config.Minimap.inventory) then
        return Config.Minimap.inventory
    end

    local candidates = { 'ox_inventory', 'qb-inventory', 'origen_inventory' }

    for _, resourceName in ipairs(candidates) do
        if isResourceStarted(resourceName) then
            return resourceName
        end
    end

    return nil
end

local function refreshRuntime()
    framework = resolveFramework()
    inventory = resolveInventory()

    if isResourceStarted('qb-core') then
        local ok, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)

        if ok then
            QBCore = core
        end
    end
end

local function hasItemServer(source, itemName)
    if not itemName or itemName == '' then
        return true
    end

    refreshRuntime()

    if inventory == 'ox_inventory' then
        local ok, count = pcall(function()
            return exports.ox_inventory:Search(source, 'count', itemName)
        end)

        return ok and (tonumber(count) or 0) > 0
    end

    if inventory == 'qb-inventory' then
        local ok, hasItem = pcall(function()
            return exports['qb-inventory']:HasItem(source, itemName, 1)
        end)

        if ok then
            return hasItem == true
        end

        if QBCore and QBCore.Functions and QBCore.Functions.GetPlayer then
            local player = QBCore.Functions.GetPlayer(source)
            if player and player.Functions and player.Functions.GetItemByName then
                return player.Functions.GetItemByName(itemName) ~= nil
            end
        end

        return false
    end

    if inventory == 'origen_inventory' then
        local ok, hasItem = pcall(function()
            return exports.origen_inventory:HasItem(source, itemName, 1)
        end)

        return ok and hasItem == true
    end

    return false
end

lib.callback.register('df_hud:server:hasMinimapItem', function(source, itemName)
    return hasItemServer(source, itemName)
end)

lib.callback.register('df_hud:server:getManualGearsPreference', function(source)
    return getManualGearsPreference(source)
end)

lib.callback.register('df_hud:server:getSupportInfo', function()
    refreshRuntime()

    return {
        framework = framework,
        inventory = inventory,
    }
end)

RegisterNetEvent('df_hud:server:setManualGearsPreference', function(enabled)
    setManualGearsPreference(source, enabled == true)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    loadManualGearsPreferences()
    refreshRuntime()

    print(('[df_hud] Server support ready. Framework: %s | Inventory: %s'):format(
        framework or 'none',
        inventory or 'none'
    ))
end)
