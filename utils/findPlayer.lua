local Services = loadstring(game:HttpGet('https://raw.githubusercontent.com/Blackout4781/Synatii-Services/main/utils/Services.lua'))()
local Players = Services:Get('Players');

return function (playerName)
    for _, v in next, Players:GetPlayers() do
        if(v.Name:lower():sub(1, #playerName) == playerName:lower()) then
            return v;
        end;
    end;
end;
