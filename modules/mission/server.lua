if GetResourceState('ox_core') == 'started' then 
        RegisterCallback("pickle_taxijob:npcMissionComplete", function(source, from, to)
            local player = GetPlayer(source, true)
        local cfg = Config.Missions
        local coords = {
            from = cfg.locations[from].xyz,
            to = cfg.locations[to].xyz,
        }
        local dist = #(coords.from - coords.to)
        if (player.DUTY) then
            local amount = math.random(cfg.reward.min, cfg.reward.max)
            local multi = cfg.reward.miles * (dist / 1000)
            amount = math.ceil(amount * multi)
            AddItem(source, cfg.reward.name, amount)
            ShowNotification(source, _L("mission_success", amount))
            return true
        else
            return false
        end
    end)
end
if GetResourceState('ox_core') ~= 'started' then 
        RegisterCallback("pickle_taxijob:npcMissionComplete", function(source, cb, from, to)
            local player = GetPlayer(source, true)
        local cfg = Config.Missions
        local coords = {
            from = cfg.locations[from].xyz,
            to = cfg.locations[to].xyz,
        }
        local dist = #(coords.from - coords.to)
        if (player.DUTY) then
            local amount = math.random(cfg.reward.min, cfg.reward.max)
            local multi = cfg.reward.miles * (dist / 1000)
            amount = math.ceil(amount * multi)
            AddItem(source, cfg.reward.name, amount)
            ShowNotification(source, _L("mission_success", amount))
            cb(true)
        else
            cb(false)
        end
    end)
end