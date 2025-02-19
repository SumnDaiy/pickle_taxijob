STATUS = {
    BUSINESS = nil,
    DUTY = false
}

local function createBlip(settings, coords)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blip, settings.id)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, settings.scale)
	SetBlipColour(blip, settings.colour)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName(settings.name)
	EndTextCommandSetBlipName(blip)
end

function GetStatus()
    return STATUS
end

function SetDutyStatus(businessID, bool)
    TriggerServerEvent("pickle_taxijob:setDutyStatus", businessID, bool)
end

function OpenVehicleMenu(businessID)
    local cfg = Config.Businesses[businessID]
    if not CanAccessGroup(cfg.groups) then
        return ShowNotification(_L("no_access"))
    end
    if not STATUS.DUTY then
        return ShowNotification(_L("not_duty"))
    end
    local options = {}
    for i=1, #cfg.vehicles do
        if CanAccessGroup(cfg.vehicles[i].groups) then
            table.insert(options, {label = cfg.vehicles[i].label, value = i})
        end
    end
    if #options < 1 then return ShowNotification(_L("vehicle_none")) end
    lib.registerMenu({
        id = 'pickle_taxijob_vehicle',
        title = _L("vehicle_menu"),
        position = 'top-right',
        options = options
    }, function(selected, scrollIndex, args)
        local ped = PlayerPedId()
        local vehicleData = cfg.vehicles[options[selected].value]
        local coords = cfg.locations.vehicle
        local vehicle = CreateVeh(vehicleData.model, coords.x, coords.y, coords.z, coords.w, true, true)
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        ShowNotification(_L("vehicle_spawned"))
    end)

    lib.showMenu('pickle_taxijob_vehicle')
end

function InteractLocation(businessID, locationID)
    if locationID == "vehicle" then
        local vehicle = GetVehiclePedIsIn(PlayerPedId())
        if vehicle ~= 0 then
            TaskLeaveAnyVehicle(PlayerPedId())
            Wait(1500)
            DeleteEntity(vehicle)
            ShowNotification(_L("vehicle_stored"))
        else
            OpenVehicleMenu(businessID)
        end
    elseif locationID == "boss" then
        AccessBossMenu(businessID)
    elseif locationID == "duty" then
        SetDutyStatus(businessID, not STATUS.DUTY)
    end
end

function DisplayHelp(businessID, locationID)
    if locationID == "vehicle" then
        if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
            ShowHelpNotification(_L("marker_remove_vehicle"))
        else
            ShowHelpNotification(_L("marker_interact_vehicle"))
        end
    elseif locationID == "boss" then
        ShowHelpNotification(_L("marker_interact_boss"))
    elseif locationID == "duty" then
        ShowHelpNotification(_L("marker_interact_duty", STATUS.DUTY and "off" or "on"))
    end
end

RegisterNetEvent("pickle_taxijob:onDutyUpdate", function(businessID, bool)
    STATUS.BUSINESS = businessID
    STATUS.DUTY = bool
end)

CreateThread(function()
    for i=1, #Config.Businesses do
        if Config.Businesses[i].blip then
            CreateBlip(Config.Businesses[i].blip)
        end
    end
    --[[ while true do 
        local wait = 1000
        for i=1, #Config.Businesses do 
            local cfg = Config.Businesses[i]
            local ped = PlayerPedId()
            local pcoords = GetEntityCoords(ped)
            for k,v in pairs(cfg.locations) do 
                local coords = v3(v)
                local dist = #(coords - pcoords)
                if (dist < 20) then
                    wait = 0
                    DrawMarker(2, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255, 127, false, true)
                    if (dist < 1.25 and not DisplayHelp(i, k) and IsControlJustPressed(1, 51)) then
                        InteractLocation(i, k)
                    end
                end
            end
        end
        Wait(wait)
    end ]]
end)
--
-- Create Zones and Blips
local hasTextUi = false

local function nearby(self)

    DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255, 127, false, true)

    if self.currentDistance < 1 and IsControlJustReleased(0, 51) then
        lib.hideTextUI()
        InteractLocation(self.businessID, self.locationID)
    end
end

local function onEnter(self)
    hasTextUi = true
    DisplayHelp(self.businessID, self.locationID)
end

local function onExit()
    if hasTextUi then
        lib.hideTextUI()
    end
end

for i=1, #Config.Businesses do
    local cfg = Config.Businesses[i]
    for k,v in pairs(cfg.locations) do
        for p = 1, #k do
            lib.points.new({
                coords = v.xyz,
                distance = 5,
                nearby = nearby,
                onEnter = onEnter,
                onExit = onExit,
                businessID = i,
                locationID = k,
            })
        end
    end
end