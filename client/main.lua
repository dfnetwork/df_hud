

local HIDE_COMPONENTS = {1,2,3,4,5,6,7,8,9,13,14,17,19,20,21}
local hunger  = 100
local thirst  = 100
local oxygen  = 100
local stamina = 100

local function isResourceStarted(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started' or state == 'starting'
end

local function getConfiguredKeybind(action, fallback)
    if type(Config.Keybinds) ~= 'table' then
        return fallback
    end

    local key = Config.Keybinds[action]
    if type(key) ~= 'string' or key == '' then
        return fallback
    end

    return key
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

local framework = resolveFramework()
local QBCore = nil
local playerLoaded = false
local detectedInventory = nil
local hudHidden = false
local cinemaHidden = false
local minimapItemOwned = false
local radarVisible = nil
local manualMode = false
local manualGear = 0
local manualVehicle = 0
local manualBaseMaxSpeed = nil
local nextManualShiftAt = 0
local clutchHeld = false
local playerManualGearsEnabled = Config.ManualGears.defaultEnabled == true

local function getServerLocale()
    return GetLocale(Config.Language or Config.Locale)
end

local function loadManualGearsPreference()
    if not Config.ManualGears.enabled then
        playerManualGearsEnabled = false
        return false
    end

    local ok, enabled = pcall(function()
        return lib.callback.await('df_hud:server:getManualGearsPreference', false)
    end)

    if ok then
        playerManualGearsEnabled = enabled == true
        return true
    end

    playerManualGearsEnabled = Config.ManualGears.defaultEnabled == true
    return false
end

local function sendServerConfig()
    SendNUIMessage({
        type = 'setServerConfig',
        config = Config.Defaults,
        locale = Config.Language or Config.Locale,
        translations = getServerLocale(),
        logo = Config.Logo,
        manualGears = {
            enabled = Config.ManualGears.enabled == true,
            playerEnabled = playerManualGearsEnabled == true
        }
    })
end

local function setRadarState(visible)
    if radarVisible == visible then
        return
    end

    radarVisible = visible
    DisplayRadar(visible)
    if visible then
        SetRadarBigmapEnabled(false, false)
    end
    SendNUIMessage({ type = 'setMinimapVisible', visible = visible })
end

local function refreshFramework()
    framework = resolveFramework()

    if not framework then
        print('[df_hud] No compatible framework detected. Expected qbx_core or qb-core.')
        return
    end

    if Config.Framework ~= 'auto' and framework ~= Config.Framework then
        print(('[df_hud] Preferred framework "%s" not available, falling back to "%s".'):format(Config.Framework, framework))
    end
end

local function loadCoreObject()
    refreshFramework()

    if not isResourceStarted('qb-core') then
        return nil
    end

    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if ok then
        return core
    end

    return nil
end

local function getPlayerData()
    QBCore = QBCore or loadCoreObject()

    if not QBCore or not QBCore.Functions or not QBCore.Functions.GetPlayerData then
        return {}
    end

    local ok, playerData = pcall(function()
        return QBCore.Functions.GetPlayerData()
    end)

    if ok and type(playerData) == 'table' then
        return playerData
    end

    return {}
end

local function updateNeedsFromPlayerData(playerData)
    local metadata = playerData and playerData.metadata or nil
    if type(metadata) ~= 'table' then
        return
    end

    hunger = metadata.hunger or hunger
    thirst = metadata.thirst or thirst
end

local function syncPlayerLoadedState()
    local playerData = getPlayerData()
    playerLoaded = playerData.citizenid ~= nil or LocalPlayer.state.isLoggedIn == true
    updateNeedsFromPlayerData(playerData)
end

local function loadSavedStyles()
    local savedStyle = GetResourceKvpString('df_hud:style')
    if savedStyle and savedStyle ~= '' then
        SendNUIMessage({ type = 'setStyle', style = savedStyle })
    end

    local savedSpeedo = GetResourceKvpString('df_hud:speedo-style')
    if savedSpeedo and savedSpeedo ~= '' then
        SendNUIMessage({ type = 'setSpeedoStyle', style = savedSpeedo })
    end
end

local function getVoiceDistance()
    local proximity = LocalPlayer.state.proximity
    if type(proximity) == 'table' and proximity.distance then
        return tonumber(proximity.distance) or 3.0
    end

    local ok, distance = pcall(MumbleGetTalkerProximity)
    if ok then
        return tonumber(distance) or 3.0
    end

    return 3.0
end

local function getVoiceMode(distance)
    if distance <= 1.6 then
        return 'whisper'
    end

    if distance <= 3.5 then
        return 'normal'
    end

    return 'shout'
end

local function getRadioState()
    local state = LocalPlayer.state
    local channel = tonumber(state.radioChannel or state.radioId or 0) or 0
    local active = state.radioPressed == true or state.radioTalking == true or state.radioActive == true
    return active, channel
end

local function resolveInventory()
    if detectedInventory and isResourceStarted(detectedInventory) then
        return detectedInventory
    end

    local configured = Config.Minimap.inventory
    local candidates = configured ~= 'auto'
        and { configured }
        or { 'ox_inventory', 'qb-inventory', 'origen_inventory' }

    for _, inventoryName in ipairs(candidates) do
        if isResourceStarted(inventoryName) then
            detectedInventory = inventoryName
            return detectedInventory
        end
    end

    detectedInventory = nil
    return nil
end

local function hasMinimapItem()
    if not Config.Minimap.item or Config.Minimap.item == '' then
        return true
    end

    local inventory = resolveInventory()
    if not inventory then
        return false
    end

    if inventory == 'ox_inventory' then
        local ok, count = pcall(function()
            return exports.ox_inventory:Search('count', Config.Minimap.item)
        end)

        return ok and (tonumber(count) or 0) > 0
    end

    if inventory == 'qb-inventory' then
        QBCore = QBCore or loadCoreObject()

        if QBCore and QBCore.Functions and QBCore.Functions.HasItem then
            local ok, hasItem = pcall(function()
                return QBCore.Functions.HasItem(Config.Minimap.item)
            end)

            if ok then
                return hasItem == true
            end
        end

        local ok, hasItem = pcall(function()
            return exports['qb-inventory']:HasItem(Config.Minimap.item)
        end)

        if ok then
            return hasItem == true
        end

        local fallbackOk, fallbackHasItem = pcall(function()
            return exports['qb-inventory']:HasItem(cache.serverId, Config.Minimap.item, 1)
        end)

        return fallbackOk and fallbackHasItem == true
    end

    if inventory == 'origen_inventory' then
        local ok, hasItem = pcall(function()
            return exports.origen_inventory:hasItem(Config.Minimap.item)
        end)

        return ok and hasItem == true
    end

    return false
end

local function updateMinimapItemState()
    if not playerLoaded then
        minimapItemOwned = false
        return
    end

    if not Config.Minimap.item or Config.Minimap.item == '' then
        minimapItemOwned = true
        return
    end

    local ok, hasItem = pcall(function()
        return lib.callback.await('df_hud:server:hasMinimapItem', false, Config.Minimap.item)
    end)

    if ok then
        minimapItemOwned = hasItem == true
        return
    end

    minimapItemOwned = hasMinimapItem()
end

local function updateRadarVisibility()
    local shouldShow = false

    if not hudHidden and not cinemaHidden and playerLoaded then
        if IsPedInAnyVehicle(cache.ped, false) then
            shouldShow = true
        else
            shouldShow = minimapItemOwned
        end
    end

    setRadarState(shouldShow)
end

local function shouldProtectStamina(ped)
    if not ped or ped == 0 then
        return false
    end

    if not IsPedOnFoot(ped) or IsPedInAnyVehicle(ped, false) then
        return false
    end

    if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) or IsPedRagdoll(ped) or IsPedFalling(ped) then
        return false
    end

    local speed = GetEntitySpeed(ped)
    local sprintPressed = IsControlPressed(0, 21)
    local actuallySprinting = speed > 0.45 and (IsPedSprinting(ped) or IsPedRunning(ped))

    return sprintPressed and not actuallySprinting
end

local function manualSupportedVehicle(vehicleClass)
    return vehicleClass ~= 8 and vehicleClass ~= 13 and vehicleClass ~= 14 and vehicleClass ~= 15 and vehicleClass ~= 16
end

local function manualGearsAvailable()
    return Config.ManualGears.enabled and playerManualGearsEnabled
end

local function resetManualGearState(vehicle)
    if vehicle and vehicle ~= 0 and manualBaseMaxSpeed then
        SetEntityMaxSpeed(vehicle, manualBaseMaxSpeed)
    end

    manualMode = false
    manualGear = 0
    manualVehicle = 0
    manualBaseMaxSpeed = nil
    nextManualShiftAt = 0
    clutchHeld = false
end

local function setManualMode(vehicle, active)
    if vehicle == 0 then
        return
    end

    if active and not manualGearsAvailable() then
        return
    end

    manualMode = active == true
    manualGear = math.max(0, math.min(Config.ManualGears.maxGears, manualGear))

    if not manualBaseMaxSpeed then
        manualBaseMaxSpeed = GetVehicleEstimatedMaxSpeed(vehicle)
    end

    if not manualMode and manualBaseMaxSpeed then
        SetEntityMaxSpeed(vehicle, manualBaseMaxSpeed)
    end
end

local function canShiftWithoutClutch()
    return not Config.ManualGears.requireClutch or clutchHeld
end

local function getManualGearDisplay()
    if manualGear <= 0 then
        return 'N'
    end

    return tostring(manualGear)
end

local function canShiftManual()
    return GetGameTimer() >= nextManualShiftAt
end

local function queueManualShiftCooldown()
    nextManualShiftAt = GetGameTimer() + Config.ManualGears.shiftCooldown
end

CreateThread(function()
    while true do
        Wait(0)
        DisplayHud(false)
        for _, id in ipairs(HIDE_COMPONENTS) do
            HideHudComponentThisFrame(id)
        end
    end
end)

CreateThread(function()
    RequestStreamedTextureDict('mphud', true)
    while not HasStreamedTextureDictLoaded('mphud') do Wait(100) end
    AddReplaceTexture('mphud', 'health_seg_simple',  'mphud', 'radar_mask')
    AddReplaceTexture('mphud', 'armour_seg_simple',  'mphud', 'radar_mask')
    AddReplaceTexture('mphud', 'health_seg_rounded', 'mphud', 'radar_mask')
    AddReplaceTexture('mphud', 'armour_seg_rounded', 'mphud', 'radar_mask')
end)

CreateThread(function()
    local minimap = RequestScaleformMovie('minimap')
    while not HasScaleformMovieLoaded(minimap) do Wait(0) end
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

CreateThread(function()
    while true do
        Wait(playerLoaded and Config.Minimap.checkInterval or 1000)
        updateMinimapItemState()
        updateRadarVisibility()
    end
end)

CreateThread(function()
    local pausedHidden = false
    while true do
        Wait(200)
        local pause = IsPauseMenuActive()
        if pause ~= pausedHidden then
            pausedHidden = pause
            SendNUIMessage({ type = 'setPauseHidden', hidden = pause })
        end
    end
end)

RegisterCommand('hud', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'openMenu' })
end, false)

RegisterCommand('cine', function()
    SendNUIMessage({ type = 'toggleCinemaCommand' })
end, false)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('selectStyle', function(data, cb)
    SetResourceKvp('df_hud:style', data.style)
    SendNUIMessage({ type = 'setStyle', style = data.style })
    cb('ok')
end)

RegisterNUICallback('selectSpeedoStyle', function(data, cb)
    SetResourceKvp('df_hud:speedo-style', data.style)
    SendNUIMessage({ type = 'setSpeedoStyle', style = data.style })
    cb('ok')
end)

RegisterNUICallback('setHideHud', function(data, cb)
    hudHidden = data.hide
    updateRadarVisibility()
    cb('ok')
end)

RegisterNUICallback('setCinema', function(data, cb)
    cinemaHidden = data.cinema
    updateRadarVisibility()
    cb('ok')
end)

RegisterNUICallback('setManualGearsEnabled', function(data, cb)
    playerManualGearsEnabled = data.enabled == true
    TriggerServerEvent('df_hud:server:setManualGearsPreference', playerManualGearsEnabled)

    if not manualGearsAvailable() then
        local vehicle = IsPedInAnyVehicle(cache.ped, false) and GetVehiclePedIsIn(cache.ped, false) or 0
        resetManualGearState(vehicle)
    end

    cb('ok')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore = QBCore or loadCoreObject()
    Wait(1000)
    playerLoaded = true
    updateNeedsFromPlayerData(getPlayerData())
    loadManualGearsPreference()
    updateMinimapItemState()
    loadSavedStyles()
    SendNUIMessage({ type = 'setVisible', visible = true })
    sendServerConfig()
    updateRadarVisibility()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    playerLoaded = false
    minimapItemOwned = false
    playerManualGearsEnabled = Config.ManualGears.defaultEnabled == true
    SendNUIMessage({ type = 'setVisible', visible = false })
    updateRadarVisibility()
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    playerLoaded = false
    minimapItemOwned = false
    playerManualGearsEnabled = Config.ManualGears.defaultEnabled == true
    SendNUIMessage({ type = 'setVisible', visible = false })
    updateRadarVisibility()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
    if type(playerData) ~= 'table' then
        return
    end

    playerLoaded = playerData.citizenid ~= nil or playerLoaded
    updateNeedsFromPlayerData(playerData)
end)

AddStateBagChangeHandler('hunger', ('player:%s'):format(cache.serverId), function(_, _, value)
    hunger = value
end)
AddStateBagChangeHandler('thirst', ('player:%s'):format(cache.serverId), function(_, _, value)
    thirst = value
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    QBCore = loadCoreObject()
    SendNUIMessage({ type = 'setVisible', visible = false })
    Wait(500)
    syncPlayerLoadedState()
    loadManualGearsPreference()
    updateMinimapItemState()
    loadSavedStyles()
    SendNUIMessage({ type = 'setVisible', visible = playerLoaded })
    SendNUIMessage({ type = 'setBlinkerInterval', interval = Config.Blinker.interval })
    sendServerConfig()
    updateRadarVisibility()
end)

CreateThread(function()
    while true do
        Wait(playerLoaded and 200 or 1000)
        if not playerLoaded then goto oxy_continue end

        local ped = cache.ped
        if IsPedSwimmingUnderWater(ped) then
            oxygen = math.max(0, oxygen - 2.0)
            if oxygen <= 0 then

                local currentHealth = GetEntityHealth(ped)
                if currentHealth > 101 then
                    SetEntityHealth(ped, currentHealth - 1)
                end
            end
        else
            oxygen = math.min(100, oxygen + 2.0)
        end

        ::oxy_continue::
    end
end)

CreateThread(function()
    while true do
        Wait(playerLoaded and 120 or 1000)
        if not playerLoaded then
            stamina = 100
            goto stamina_continue
        end

        local ped = cache.ped
        if shouldProtectStamina(ped) then
            RestorePlayerStamina(PlayerId(), 1.0)
        end

        stamina = math.max(0, math.min(100, math.floor(GetPlayerStamina(PlayerId()))))

        ::stamina_continue::
    end
end)

CreateThread(function()
    while true do
        Wait(playerLoaded and Config.Stats.updateInterval or 1000)
        if playerLoaded then
            local ped = cache.ped
            SendNUIMessage({
                type    = 'stats',
                health  = math.max(0, math.min(100, GetEntityHealth(ped) - 100)),
                armour  = math.max(0, math.min(100, math.floor(GetPedArmour(ped)))),
                hunger  = math.max(0, math.min(100, math.floor(hunger))),
                thirst  = math.max(0, math.min(100, math.floor(thirst))),
                stamina = math.max(0, math.min(100, stamina)),
                oxygen  = math.max(0, math.min(100, math.floor(oxygen))),
            })
        end
    end
end)

CreateThread(function()
    while true do
        Wait((Config.Voice.enabled and playerLoaded) and Config.Voice.updateInterval or 1000)
        if not Config.Voice.enabled or not playerLoaded then
            goto voice_continue
        end

        local playerId = PlayerId()
        local distance = getVoiceDistance()
        local talking = NetworkIsPlayerTalking(playerId)
        local radioActive, radioChannel = getRadioState()

        SendNUIMessage({
            type = 'voice',
            talking = talking,
            range = distance,
            mode = getVoiceMode(distance),
            radioActive = radioActive,
            radioChannel = radioChannel
        })

        ::voice_continue::
    end
end)

local blinkerLeft  = false
local blinkerRight = false
local hazardOn     = false
local seatbelt     = false
local lightsMode   = 0
local wasInVehicle = false
local prevAltitude = 0.0
local prevSpeed    = 0
local prevVelocity = vector3(0, 0, 0)

local function hudInputBlocked()
    return IsPauseMenuActive() or IsNuiFocused()
end

RegisterKeyMapping('+df_blink_left',  'Intermitente izquierdo',  'keyboard', getConfiguredKeybind('blinkLeft', 'left'))
RegisterKeyMapping('+df_blink_right', 'Intermitente derecho',    'keyboard', getConfiguredKeybind('blinkRight', 'right'))
RegisterKeyMapping('+df_hazard',      'Luces de emergencia',     'keyboard', getConfiguredKeybind('hazard', 'down'))
RegisterKeyMapping('+df_seatbelt',    'Cinturón de seguridad',   'keyboard', getConfiguredKeybind('seatbelt', 'b'))
RegisterKeyMapping('+df_manual_toggle', 'Marchas manuales', 'keyboard', getConfiguredKeybind('manualToggle', 'k'))
RegisterKeyMapping('+df_gear_up', 'Subir marcha manual', 'keyboard', getConfiguredKeybind('gearUp', 'pageup'))
RegisterKeyMapping('+df_gear_down', 'Bajar marcha manual', 'keyboard', getConfiguredKeybind('gearDown', 'pagedown'))
RegisterKeyMapping('+df_clutch', 'Embrague', 'keyboard', getConfiguredKeybind('clutch', 'lshift'))

RegisterCommand('+df_blink_left', function()
    if hudInputBlocked() then return end
    local ped = cache.ped
    if not IsPedInAnyVehicle(ped, false) then return end
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetVehicleClass(vehicle) == 13 then return end
    hazardOn     = false
    blinkerRight = false
    blinkerLeft  = not blinkerLeft
    SetVehicleIndicatorLights(vehicle, 0, false)
    SetVehicleIndicatorLights(vehicle, 1, blinkerLeft)
end, false)
RegisterCommand('-df_blink_left', function() end, false)

RegisterCommand('+df_blink_right', function()
    if hudInputBlocked() then return end
    local ped = cache.ped
    if not IsPedInAnyVehicle(ped, false) then return end
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetVehicleClass(vehicle) == 13 then return end
    hazardOn      = false
    blinkerLeft   = false
    blinkerRight  = not blinkerRight
    SetVehicleIndicatorLights(vehicle, 1, false)
    SetVehicleIndicatorLights(vehicle, 0, blinkerRight)
end, false)
RegisterCommand('-df_blink_right', function() end, false)

RegisterCommand('+df_hazard', function()
    if hudInputBlocked() then return end
    local ped = cache.ped
    if not IsPedInAnyVehicle(ped, false) then return end
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetVehicleClass(vehicle) == 13 then return end
    hazardOn     = not hazardOn
    blinkerLeft  = hazardOn
    blinkerRight = hazardOn
    SetVehicleIndicatorLights(vehicle, 0, hazardOn)
    SetVehicleIndicatorLights(vehicle, 1, hazardOn)
end, false)
RegisterCommand('-df_hazard', function() end, false)

RegisterCommand('+df_seatbelt', function()
    if hudInputBlocked() then return end
    if not IsPedInAnyVehicle(cache.ped, false) then return end
    local vc = GetVehicleClass(GetVehiclePedIsIn(cache.ped, false))
    if vc == 8 or vc == 13 then return end
    seatbelt = not seatbelt
    SendNUIMessage({ type = 'seatbeltSound', buckled = seatbelt })
end, false)
RegisterCommand('-df_seatbelt', function() end, false)

RegisterCommand('+df_manual_toggle', function()
    if not manualGearsAvailable() or hudInputBlocked() then return end
    if not IsPedInAnyVehicle(cache.ped, false) then return end

    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    local vehicleClass = GetVehicleClass(vehicle)
    if not manualSupportedVehicle(vehicleClass) then return end

    manualVehicle = vehicle
    manualBaseMaxSpeed = manualBaseMaxSpeed or GetVehicleEstimatedMaxSpeed(vehicle)
    setManualMode(vehicle, not manualMode)
end, false)
RegisterCommand('-df_manual_toggle', function() end, false)

RegisterCommand('+df_gear_up', function()
    if not manualGearsAvailable() or not manualMode or not canShiftManual() or not canShiftWithoutClutch() then return end
    if not IsPedInAnyVehicle(cache.ped, false) then return end

    manualGear = math.min(Config.ManualGears.maxGears, manualGear + 1)
    queueManualShiftCooldown()
end, false)
RegisterCommand('-df_gear_up', function() end, false)

RegisterCommand('+df_gear_down', function()
    if not manualGearsAvailable() or not manualMode or not canShiftManual() or not canShiftWithoutClutch() then return end
    if not IsPedInAnyVehicle(cache.ped, false) then return end

    manualGear = math.max(0, manualGear - 1)
    queueManualShiftCooldown()
end, false)
RegisterCommand('-df_gear_down', function() end, false)

RegisterCommand('+df_clutch', function()
    if not manualGearsAvailable() or hudInputBlocked() then return end
    if not IsPedInAnyVehicle(cache.ped, false) then return end
    clutchHeld = true
end, false)
RegisterCommand('-df_clutch', function()
    clutchHeld = false
end, false)

CreateThread(function()
    while true do
        local waitMs = 250
        if IsPedInAnyVehicle(cache.ped, false) then
            if seatbelt then
                waitMs = 0
                DisableControlAction(0, 75, true)
            end

            if manualMode and (clutchHeld or manualGear == 0) then
                waitMs = 0
                DisableControlAction(0, 71, true)
            end
        end

        if seatbelt and IsPedInAnyVehicle(cache.ped, false) then
            waitMs = 0
        end
        Wait(waitMs)
    end
end)

RegisterKeyMapping('+df_headlights', 'Luces del vehículo', 'keyboard', getConfiguredKeybind('headlights', 'h'))

RegisterCommand('+df_headlights', function()
    if hudInputBlocked() then return end
    local ped = cache.ped
    if not IsPedInAnyVehicle(ped, false) then return end
    local vehicle  = GetVehiclePedIsIn(ped, false)
    lightsMode = (lightsMode + 1) % 3
    if lightsMode == 0 then
        SetVehicleLights(vehicle, 1)
        SetVehicleFullbeam(vehicle, false)
    elseif lightsMode == 1 then
        SetVehicleLights(vehicle, 2)
        SetVehicleFullbeam(vehicle, false)
    else
        SetVehicleLights(vehicle, 2)
        SetVehicleFullbeam(vehicle, true)
    end
end, false)
RegisterCommand('-df_headlights', function() end, false)

CreateThread(function()
    while true do
        local waitMs = Config.Speedo.updateInterval
        if not playerLoaded then
            Wait(1000)
            goto continue
        end

        local ped       = cache.ped
        local inVehicle = IsPedInAnyVehicle(ped, false)

        if inVehicle then
            local vehicle      = GetVehiclePedIsIn(ped, false)
            local vClass       = GetVehicleClass(vehicle)
            local speed        = math.floor(GetEntitySpeed(vehicle) * 3.6)
            local fuel         = math.floor(GetVehicleFuelLevel(vehicle))
            local gear         = GetVehicleCurrentGear(vehicle)
            local rpm          = GetVehicleCurrentRpm(vehicle)
            local engineHealth = GetVehicleEngineHealth(vehicle)
            local coords       = GetEntityCoords(vehicle)
            local altitude     = math.floor(coords.z)
            local heading      = math.floor(GetEntityHeading(vehicle))
            local vertSpeed    = math.floor((coords.z - prevAltitude) / (Config.Speedo.updateInterval / 1000))
            local altAgl       = math.floor(GetEntityHeightAboveGround(vehicle))
            prevAltitude = coords.z

            local vType
            if vClass == 15 then
                vType = 'heli'
            elseif vClass == 16 then
                vType = 'plane'
            elseif vClass == 14 then
                vType = 'boat'
            elseif vClass == 13 then
                vType = 'bicycle'
            elseif vClass == 8 then
                vType = 'bike'
            else
                vType = 'car'
            end

            if manualVehicle ~= vehicle then
                manualVehicle = vehicle
                manualBaseMaxSpeed = GetVehicleEstimatedMaxSpeed(vehicle)
                manualGear = 0
                clutchHeld = false
                manualMode = manualGearsAvailable() and Config.ManualGears.defaultEnabled and manualSupportedVehicle(vClass) or false
            end

            if manualGearsAvailable() and manualMode and manualSupportedVehicle(vClass) and manualBaseMaxSpeed then
                if clutchHeld or manualGear == 0 then
                    SetEntityMaxSpeed(vehicle, math.max(2.0, speed / 3.6 + 1.5))
                else
                    local ratio = Config.ManualGears.ratios[manualGear] or 1.0
                    SetEntityMaxSpeed(vehicle, math.max(4.0, manualBaseMaxSpeed * ratio))
                end
                gear = manualGear
            elseif manualBaseMaxSpeed then
                SetEntityMaxSpeed(vehicle, manualBaseMaxSpeed)
            end

            local speedDrop = prevSpeed - speed
            if speedDrop > 25 and vType ~= 'bicycle' and vType ~= 'bike' then
                local threshold = seatbelt and 150 or 30
                if prevSpeed > threshold then
                    local prevSpeedMs = math.max(prevSpeed / 3.6, 1.0)
                    local dirX = prevVelocity.x / prevSpeedMs
                    local dirY = prevVelocity.y / prevSpeedMs
                    local force = math.min(math.max(prevSpeed * 0.12, 8.0), 22.0)
                    seatbelt = false
                    local coords = GetEntityCoords(vehicle)
                    SetEntityCoords(ped, coords.x + dirX * 1.5, coords.y + dirY * 1.5, coords.z + 0.6, false, false, false, false)
                    SetEntityVelocity(ped, dirX * force, dirY * force, 5.0)
                    SetPedToRagdoll(ped, 8000, 8000, 0, false, false, false)
                end
            end
            prevVelocity = GetEntityVelocity(vehicle)
            prevSpeed    = speed

            if vType == 'car' or vType == 'bike' then
                if speed > 10 then
                    local steer = GetVehicleSteeringAngle(vehicle)
                    if blinkerLeft  and steer >  15.0 then
                        blinkerLeft = false
                        SetVehicleIndicatorLights(vehicle, 1, false)
                    end
                    if blinkerRight and steer < -15.0 then
                        blinkerRight = false
                        SetVehicleIndicatorLights(vehicle, 0, false)
                    end
                end
            end

            if not wasInVehicle then
                updateRadarVisibility()
            end

            wasInVehicle = true
            SendNUIMessage({
                type          = 'vehicle',
                inVehicle     = true,
                vehicleType   = vType,
                speed         = speed,
                fuel          = fuel,
                gear          = gear,
                rpm           = rpm,
                altitude      = altitude,
                altAgl        = altAgl,
                heading       = heading,
                vertSpeed     = vertSpeed,
                lightsMode    = lightsMode,
                engineWarning = engineHealth < 300,
                blinkerLeft   = blinkerLeft,
                blinkerRight  = blinkerRight,
                seatbelt      = seatbelt,
                manualMode    = manualMode,
                manualGear    = manualGear,
                manualGearDisplay = getManualGearDisplay(),
                clutchHeld    = clutchHeld,
            })
        else
            if wasInVehicle then
                local lastVehicle = GetVehiclePedIsIn(cache.ped, true)
                if lastVehicle ~= 0 then
                    SetVehicleIndicatorLights(lastVehicle, 0, false)
                    SetVehicleIndicatorLights(lastVehicle, 1, false)
                end
                blinkerLeft  = false
                blinkerRight = false
                hazardOn     = false
                seatbelt     = false
                lightsMode   = 0
                prevSpeed    = 0
                prevVelocity = vector3(0, 0, 0)
                SetVehicleFullbeam(lastVehicle, false)
                wasInVehicle = false
                prevAltitude = 0.0
                resetManualGearState(lastVehicle)
                updateRadarVisibility()
            end
            SendNUIMessage({ type = 'vehicle', inVehicle = false })
            waitMs = 300
        end

        Wait(waitMs)
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(playerLoaded and 120 or 1000)
        if not playerLoaded then goto comp_continue end

        local camRot  = GetGameplayCamRot(2)
        local h       = camRot.z
        if h < 0.0 then h = h + 360.0 end
        local compass = (360.0 - h) % 360.0

        local coords    = GetEntityCoords(cache.ped)
        local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street     = GetStreetNameFromHashKey(streetHash)
        if not street or street == '' then
            street = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
        end

        SendNUIMessage({ type = 'compass', heading = compass, street = street })

        ::comp_continue::
    end
end)
