if GetResourceState('ox_core') ~= 'started' then return end

local file = ('imports/%s.lua'):format(IsDuplicityVersion() and 'server' or 'client')
local import = LoadResourceFile('ox_core', file)
local chunk = assert(load(import, ('@@ox_core/%s'):format(file)))
chunk()

function ServerCallback(name, cb, ...)
    lib.callback(name, false, cb, ...)
end

function ShowNotification(text)
    lib.notify({
        id = "taxijob",
        title = 'Taxi job',
        description = text,
        type = 'inform'
    })
end

function ShowHelpNotification(text)
    lib.showTextUI(text)
end

function CanAccessGroup(data)
    if not data then return true end
    for key, value in pairs(data) do
        for job, grade in pairs(player.groups) do
            if (job == key and grade >= value) then
                return true
            end 
        end
        return false
    end
end
    
function AccessBossMenu(businessID)
    local cfg = Config.Businesses[businessID]
    if not CanAccessGroup(cfg.bossgroups) then 
        return ShowNotification(_L("no_access"))
    end
    TriggerEvent('esx_society:openBossMenu', cfg.info.society, function(data, menu)
        menu.close()
    end, {
        withdraw = false,
        deposit = false,
        wash = true,
        employees = true,
        grades = false
    })
end