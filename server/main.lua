local framework = nil
local inventory = nil
local frameworkAdapter = nil
local inventoryAdapter = nil
local manualGearsPreferences = {}
local MANUAL_GEARS_PREFS_FILE = 'data/manual_gears_prefs.json'
local EXPECTED_RESOURCE_NAME = 'df_hud'

local function normalizePercent(value)
    local numeric = tonumber(value)
    if not numeric then
        return nil
    end

    return math.max(0, math.min(100, math.floor(numeric + 0.5)))
end

local function tr(key, fallback)
    local locale = GetLocale(Config.Language or Config.Locale)
    return locale[key] or fallback
end

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
    return DFHUD.isResourceStarted(resourceName)
end

local function getConfiguredInventory()
    local preferred = Config.Inventory
    if type(preferred) == 'string' and preferred ~= '' and preferred:lower() ~= 'auto' then
        return preferred
    end

    local legacy = Config.Minimap and Config.Minimap.inventory or nil
    if type(legacy) == 'string' and legacy ~= '' then
        return legacy
    end

    return 'auto'
end

local function refreshRuntime()
    framework = DFHUD.detectFramework(Config.Framework)
    inventory = DFHUD.detectInventory(getConfiguredInventory())
    frameworkAdapter = DFHUD.getServerFrameworkAdapter(framework)
    inventoryAdapter = DFHUD.getServerInventoryAdapter(inventory)

    if frameworkAdapter and frameworkAdapter.boot then
        frameworkAdapter:boot()
    end
end

local function hasItemServer(source, itemName)
    if not itemName or itemName == '' then
        return true
    end

    refreshRuntime()
    if not inventoryAdapter or not inventoryAdapter.hasItem then
        return false
    end

    return inventoryAdapter.hasItem(source, itemName, {
        getFrameworkAdapter = function()
            return frameworkAdapter
        end,
    }) == true
end

local function getNeedsSnapshot(source)
    refreshRuntime()
    if not frameworkAdapter or not frameworkAdapter.getNeeds then
        return {}
    end

    local needs = frameworkAdapter:getNeeds(source) or {}
    return {
        hunger = normalizePercent(needs.hunger),
        thirst = normalizePercent(needs.thirst),
    }
end

local function compareVersions(localVersion, remoteVersion)
    local function split(version)
        local parts = {}
        for token in tostring(version or ''):gmatch('[^.]+') do
            parts[#parts + 1] = tonumber(token) or 0
        end
        return parts
    end

    local left = split(localVersion)
    local right = split(remoteVersion)
    local size = math.max(#left, #right)

    for index = 1, size do
        local a = left[index] or 0
        local b = right[index] or 0
        if a ~= b then
            return a < b and -1 or 1
        end
    end

    return 0
end

local function formatStartupValue(value, noneKey, noneFallback)
    if value and value ~= '' then
        return value
    end

    return tr(noneKey, noneFallback)
end

local function printStartupBanner(versionSummary)
    local resourceName = GetCurrentResourceName()
    local localVersion = GetResourceMetadata(resourceName, 'version', 0) or '0.0.0'
    local customSupportEnabled = framework == 'custom' or inventory == 'custom'
    local renamedResource = resourceName ~= EXPECTED_RESOURCE_NAME

    print(tr('debug-banner-line', '========================================================'))
    print(('[%s]'):format(resourceName))
    print(('* %s: %s'):format(
        tr('debug-author', 'DF Network'),
        formatStartupValue(GetResourceMetadata(resourceName, 'author', 0), 'debug-author-missing', 'Unknown')
    ))
    print(('* %s: %s'):format(
        tr('debug-framework', 'Framework'),
        formatStartupValue(framework, 'debug-framework-none', 'No framework detected')
    ))
    print(('* %s: %s'):format(
        tr('debug-inventory', 'Inventory'),
        formatStartupValue(inventory, 'debug-inventory-none', 'No inventory resource found')
    ))
    print(('* %s: %s'):format(
        tr('debug-voice', 'Voice HUD'),
        Config.Voice.enabled and tr('debug-enabled', 'Enabled') or tr('debug-disabled', 'Disabled')
    ))
    print(('* %s: %s'):format(
        tr('debug-manual-gears', 'Manual gears'),
        Config.ManualGears.enabled and tr('debug-enabled', 'Enabled') or tr('debug-disabled', 'Disabled')
    ))
    print(('* %s: %s'):format(
        tr('debug-version', 'Version'),
        versionSummary or localVersion
    ))
    print(('* %s: %s'):format(
        tr('debug-updates', 'Updates'),
        Config.Updates.repoUrl
    ))
    print(('* %s: %s'):format(
        tr('debug-resource-name', 'Required resource name'),
        tr('debug-resource-rename-note', 'This resource cannot be renamed and must be called df_hud')
    ))
    if renamedResource then
        print(('* %s: %s'):format(
            tr('debug-warning', 'Warning'),
            tr('debug-resource-rename-error', 'Invalid resource name detected. Rename the folder/resource back to df_hud or it will not work correctly')
        ))
    end
    if customSupportEnabled then
        print(('* %s: %s'):format(
            tr('debug-support', 'Support'),
            tr('debug-custom-ticket', 'Custom framework/inventory detected | Open a ticket at discord.gg/dfnetwork for official support')
        ))
    end
    print(tr('debug-banner-line', '========================================================'))
end

local function enforceExpectedResourceName()
    local resourceName = GetCurrentResourceName()
    if resourceName == EXPECTED_RESOURCE_NAME then
        return true
    end

    local localVersion = GetResourceMetadata(resourceName, 'version', 0) or '0.0.0'
    printStartupBanner(('%s | %s'):format(
        localVersion,
        tr('debug-resource-stop', 'Resource stopped due to invalid resource name')
    ))
    StopResource(resourceName)
    return false
end

local function checkRemoteVersionAndPrint()
    local localVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '0.0.0'

    if not (Config.Debug and Config.Debug.enabled and Config.Debug.versionCheck) then
        printStartupBanner(localVersion)
        return
    end

    PerformHttpRequest(Config.Updates.manifestUrl, function(statusCode, body)
        if statusCode ~= 200 or type(body) ~= 'string' then
            printStartupBanner(('%s | %s'):format(localVersion, tr('debug-version-error', 'Version check failed')))
            return
        end

        local remoteVersion = body:match("df_hud%s*=%s*['\"]([^'\"]+)['\"]")
        if not remoteVersion then
            printStartupBanner(('%s | %s'):format(localVersion, tr('debug-version-missing', 'No entry found in remote manifest')))
            return
        end

        if compareVersions(localVersion, remoteVersion) < 0 then
            printStartupBanner(('%s | %s: %s'):format(localVersion, tr('debug-version-update', 'Update available'), remoteVersion))
            return
        end

        printStartupBanner(('%s | %s'):format(localVersion, tr('debug-version-latest', 'Latest version')))
    end, 'GET', '', {}, { followLocation = true })
end

lib.callback.register('df_hud:server:hasMinimapItem', function(source, itemName)
    return hasItemServer(source, itemName)
end)

lib.callback.register('df_hud:server:getManualGearsPreference', function(source)
    return getManualGearsPreference(source)
end)

lib.callback.register('df_hud:server:getNeedsSnapshot', function(source)
    return getNeedsSnapshot(source)
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

    if not enforceExpectedResourceName() then
        return
    end

    loadManualGearsPreferences()
    refreshRuntime()
    checkRemoteVersionAndPrint()
end)
