DFHUD = DFHUD or {}

DFHUD.FrameworkDefinitions = {
    qbx = { resources = { 'qbx_core' }, aliases = { 'qbox' } },
    qbcore = { resources = { 'qb-core' } },
    esx = { resources = { 'es_extended' } },
    mythic = { resources = { 'mythic-base' } },
    nd = { resources = { 'ND_Core' } },
    ox = { resources = { 'ox_core' } },
    vrp = { resources = { 'vrp' } },
    vrpex = { resources = { 'vrpex', 'vrp' } },
    custom = { resources = {}, aliases = { 'custom' } },
}

DFHUD.FrameworkOrder = { 'qbx', 'qbcore', 'esx', 'mythic', 'nd', 'ox', 'vrp', 'vrpex', 'custom' }

DFHUD.InventoryDefinitions = {
    ['ox_inventory'] = { resources = { 'ox_inventory' } },
    ['qs-inventory'] = { resources = { 'qs-inventory' } },
    ['qb-inventory'] = { resources = { 'qb-inventory' } },
    ['ps-inventory'] = { resources = { 'ps-inventory' } },
    ['codem-inventory'] = { resources = { 'codem-inventory' } },
    ['core_inventory'] = { resources = { 'core_inventory' } },
    ['ak47_inventory'] = { resources = { 'ak47_inventory', 'ak47_qb_inventory' }, aliases = { 'ak47_qb_inventory' } },
    ['esx_inventory'] = { resources = { 'esx_inventory', 'esx_inventoryhud', 'es_extended' }, aliases = { 'esx_inventoryhud' } },
    ['origen_inventory'] = { resources = { 'origen_inventory' } },
    ['mythic-inventory'] = { resources = { 'mythic-inventory', 'mythic-base' } },
    ['ND_Core'] = { resources = { 'ND_Core' } },
    ['vrp'] = { resources = { 'vrp' } },
    ['custom'] = { resources = {}, aliases = { 'custom' } },
}

DFHUD.InventoryOrder = {
    'ox_inventory',
    'qs-inventory',
    'qb-inventory',
    'ps-inventory',
    'codem-inventory',
    'core_inventory',
    'ak47_inventory',
    'origen_inventory',
    'esx_inventory',
    'mythic-inventory',
    'ND_Core',
    'vrp',
    'custom',
}

DFHUD.ClientFrameworkAdapters = DFHUD.ClientFrameworkAdapters or {}
DFHUD.ServerFrameworkAdapters = DFHUD.ServerFrameworkAdapters or {}
DFHUD.ClientInventoryAdapters = DFHUD.ClientInventoryAdapters or {}
DFHUD.ServerInventoryAdapters = DFHUD.ServerInventoryAdapters or {}

function DFHUD.isResourceStarted(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started' or state == 'starting'
end

local function normalizeChoice(choice)
    if type(choice) ~= 'string' then
        return nil
    end

    local lowered = choice:lower()
    if lowered == 'auto' or lowered == '' then
        return nil
    end

    return lowered
end

local function matchesAlias(choice, definition)
    if not definition or type(definition.aliases) ~= 'table' then
        return false
    end

    for _, alias in ipairs(definition.aliases) do
        if choice == alias:lower() then
            return true
        end
    end

    return false
end

local function resolvePreferredKey(choice, definitions)
    for key, definition in pairs(definitions) do
        if choice == key:lower() or matchesAlias(choice, definition) then
            return key
        end
    end

    return nil
end

function DFHUD.detectFramework(preferred)
    local preferredKey = normalizeChoice(preferred)

    if preferredKey then
        local resolvedKey = resolvePreferredKey(preferredKey, DFHUD.FrameworkDefinitions)
        if resolvedKey == 'custom' then
            return 'custom'
        end

        local definition = resolvedKey and DFHUD.FrameworkDefinitions[resolvedKey] or nil
        if definition then
            for _, resourceName in ipairs(definition.resources) do
                if DFHUD.isResourceStarted(resourceName) then
                    return resolvedKey
                end
            end
        end
    end

    for _, key in ipairs(DFHUD.FrameworkOrder) do
        local definition = DFHUD.FrameworkDefinitions[key]
        for _, resourceName in ipairs(definition.resources) do
            if DFHUD.isResourceStarted(resourceName) then
                return key
            end
        end
    end

    return nil
end

function DFHUD.detectInventory(preferred)
    local preferredKey = normalizeChoice(preferred)

    if preferredKey then
        local resolvedKey = resolvePreferredKey(preferredKey, DFHUD.InventoryDefinitions)
        if resolvedKey == 'custom' then
            return 'custom'
        end

        local definition = resolvedKey and DFHUD.InventoryDefinitions[resolvedKey] or nil
        if definition then
            for _, resourceName in ipairs(definition.resources) do
                if DFHUD.isResourceStarted(resourceName) then
                    return resolvedKey
                end
            end
        end

        if DFHUD.isResourceStarted(preferredKey) then
            return preferredKey
        end
    end

    for _, key in ipairs(DFHUD.InventoryOrder) do
        local definition = DFHUD.InventoryDefinitions[key]
        for _, resourceName in ipairs(definition.resources) do
            if DFHUD.isResourceStarted(resourceName) then
                return key
            end
        end
    end

    return nil
end

function DFHUD.getClientFrameworkAdapter(framework)
    return framework and DFHUD.ClientFrameworkAdapters[framework] or nil
end

function DFHUD.getServerFrameworkAdapter(framework)
    return framework and DFHUD.ServerFrameworkAdapters[framework] or nil
end

function DFHUD.getClientInventoryAdapter(inventory)
    return inventory and DFHUD.ClientInventoryAdapters[inventory] or nil
end

function DFHUD.getServerInventoryAdapter(inventory)
    return inventory and DFHUD.ServerInventoryAdapters[inventory] or nil
end
