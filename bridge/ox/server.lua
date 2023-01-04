if GetResourceState('ox_core') ~= 'started' then return end

local file = ('imports/%s.lua'):format(IsDuplicityVersion() and 'server' or 'client')
local import = LoadResourceFile('ox_core', file)
local chunk = assert(load(import, ('@@ox_core/%s'):format(file)))
chunk()

function RegisterCallback(name, cb)
    lib.callback.register(name, cb)
end

function ShowNotification(target, text)
    lib.notify(target, {
        id = "taxijob",
        title = 'Taxi job',
        description = text,
        type = 'inform'
    })
end

function AddItem(source, name, amount, metadata)
    exports.ox_inventory:AddItem(source, name, amount, metadata)
end

function CanAccessGroup(data)
    if not data then return true end
    for key, value in pairs(data) do
        local player = Ox.GetPlayer(source)
        for job, grade in pairs(player.getGroups(source)) do
            if (job == key and grade >= value) then
                return true
            end 
        end
        return false
    end
end