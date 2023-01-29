function GetRandomInt(min, max, exclude)
    for i=1, 1000 do
        local int = math.random(min, max)
        if exclude == nil or exclude ~= int then
            return int
        end
    end
end