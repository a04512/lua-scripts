local lhtracker = {
    OptionEnable = Menu.AddOption({"typocant", "Lash Hit Tracker"}, "Enable", "Enable/Disable this script."),
    lhBarOnKey = Menu.AddOption({"typocant", "Lash Hit Tracker"}, "On Key mode", "Last hit Bar will show only when press Key"),
    MenuKey = Menu.AddKeyOption({"typocant", "Lash Hit Tracker"}, "Show Key", Enum.ButtonCode.KEY_LALT),
    ResetKey = Menu.AddKeyOption({"typocant", "Lash Hit Tracker"}, "Reset data Key", Enum.ButtonCode.KEY_END)
}

local recv_data = nil
local my_hero = nil
local attacker = nil
local victim = nil
local player_track = {}
local enemy_team = nil
local my_team = nil
local draw_x, draw_y = 0, 0
local multiplier = 0
local font_val = Renderer.LoadFont("Helvetica Neue", 30, Enum.FontWeight.MEDIUM)

--[[
    1152 C_DOTA_BaseNPC_Creep_Lane
    20 C_DOTA_BaseNPC_Tower
--]]

local attacker_ignore = {
    [20] = true,
    [1152] = true
}

--[[
    1 hero
    256 courier
--]]

local victim_ignore = {
    [1] = true
}

function lhtracker.OnScriptLoad()
    local screen_x, screen_y = Renderer.GetScreenSize()
    lhtracker.OffsetX = Menu.AddOption({"typocant", "Lash Hit Tracker"}, "X position", "", 0, screen_x, 25, 1425)
    lhtracker.OffsetY = Menu.AddOption({"typocant", "Lash Hit Tracker"}, "Y position", "", 0, screen_y, 25, 0)
    local configContent = Config.ReadFile("lhtracker.json")
    if configContent == nil then
        Config.WriteFile("lhtracker.json", "{}")
        Log.Write("Data config not found, created lhtracker.json config.")
    end
    my_hero = nil
    recv_data = nil
    attacker = nil
    victim = nil
    enemy_team = nil
    my_team = nil
    player_track = JSON.Decode(Config.ReadFile("lhtracker.json"))
    for _, v in pairs(player_track) do
        v.last_hit = math.floor(v.last_hit)
        v.denied = math.floor(v.denied)
    end
    multiplier = 0
    draw_x, draw_y = Menu.GetValue(lhtracker.OffsetX), Menu.GetValue(lhtracker.OffsetY)
end

function lhtracker.OnMenuOptionChange(option, old, new)
    if (option == lhtracker.OffsetX or option == lhtracker.OffsetY) then
		draw_x, draw_y = Menu.GetValue(lhtracker.OffsetX), Menu.GetValue(lhtracker.OffsetY)
        multiplier = 0
    end
end

function lhtracker.OnGameEnd()
    if Menu.IsEnabled(lhtracker.OptionEnable) == false then return end
	my_hero = nil
    recv_data = nil
    attacker = nil
    victim = nil
	enemy_team = nil
    my_team = nil
    multiplier = 0
end

--[[
    Mapping
    "entity_killed"
	{
		"entindex_killed" 	"long"
		"entindex_attacker"	"long"
		"entindex_inflictor"	"long"
		"damagebits"		"long"
	}
--]]

function lhtracker.OnGameEvent(event)
    if Menu.IsEnabled(lhtracker.OptionEnable) == false then return end
    if my_hero == nil then return end
    if event.name == "entity_killed" then
        recv_data = event.data
        attacker = Entities.GetEntityByIndex(recv_data.entindex_attacker)
        victim = Entities.GetEntityByIndex(recv_data.entindex_killed)
        
        if Entity.IsEntity(attacker) and Entity.IsEntity(victim) then
            lhtracker.trackLH(enemy_team, recv_data, attacker, victim)
            lhtracker.trackLH(my_team, recv_data, attacker, victim)
        end
    end
end

function lhtracker.trackLH(team, recv_data, attacker, victim)
    
    if Entity.GetTeamNum(attacker) == team then 
        if Entity.GetTeamNum(victim) == team and Entity.GetField(victim, "m_nPlayerOwnerID") ~= -1 then return end
        if attacker_ignore[Entity.GetField(attacker, "m_iUnitType")] then return end
        if victim_ignore[Entity.GetField(victim, "m_iUnitType")] then return end
        local attacker_owner = tostring(Entity.GetField(attacker, "m_nPlayerOwnerID"))
        
        if attacker_owner == "-1" then
            attacker_owner = tostring(Player.GetPlayerID(Entity.GetOwner(attacker)))
        end
        
        if player_track[attacker_owner] == nil then
            local attacker_class = Entity.GetClassName(attacker)
            local hero_icon
            if Entity.GetField(attacker, "m_nPlayerOwnerID") ~= -1 then
                attacker_class = Entity.GetClassName(Entity.GetOwner(attacker))
                hero_icon = "panorama/images/heroes/icons/" .. NPC.GetUnitName(Entity.GetOwner(attacker)) .. "_png.vtex_c"
            else
                hero_icon = "panorama/images/heroes/icons/" .. NPC.GetUnitName(attacker) .. "_png.vtex_c"
            end
            player_track[attacker_owner] = {
                last_hit = 0,
                denied = 0,
                class = attacker_class,
                icon = hero_icon,
                team = team
            }
        end
        
        if Entity.GetTeamNum(victim) == team then
            player_track[attacker_owner].denied = player_track[attacker_owner].denied + 1
        else
            player_track[attacker_owner].last_hit = player_track[attacker_owner].last_hit + 1
        end
    end
end

function lhtracker.OnUpdate()
    if Menu.IsEnabled(lhtracker.OptionEnable) == false then return end
    
    if my_hero == nil or my_hero ~= Heroes.GetLocal() then
        
        recv_data = nil
        attacker = nil
        victim = nil
        my_hero = Heroes.GetLocal()
		my_team = Entity.GetTeamNum(my_hero)
        if my_team == 2 then
            enemy_team = 3
        else
            enemy_team = 2
        end
        draw_x, draw_y = Menu.GetValue(lhtracker.OffsetX), Menu.GetValue(lhtracker.OffsetY)
        multiplier = 0
        GameEvents.StartListening("entity_killed")
		return
	end
end

function lhtracker.reset()
    Config.WriteFile("lhtracker.json", "{}")
    Log.Write("Data config reseted")
    player_track = {}
end

function lhtracker.OnDraw()
    if Menu.IsEnabled(lhtracker.OptionEnable) == false then return end

    if Menu.IsKeyDownOnce(lhtracker.ResetKey) then
        lhtracker.reset()
    end

    if Menu.IsEnabled(lhtracker.lhBarOnKey) == true then
        if not Menu.IsKeyDown(lhtracker.MenuKey) then return end 
    end
	
    if my_hero == nil then return end
    
    sorted = lhtracker.sortByLh()
    multiplier = 0
    Renderer.SetDrawColor(0, 200, 100, 255)
    Renderer.DrawText(font_val, draw_x, draw_y + multiplier, "LH/DN: ", 0)
    multiplier = multiplier + 28
    for _, v in pairs(sorted) do
        if v.team == my_team then
            Renderer.SetDrawColor(0, 255, 0, 100)
        else
            Renderer.SetDrawColor(255, 0, 0, 100)
        end
        Renderer.DrawFilledRect(draw_x + 28, draw_y + multiplier, 70, 28)
        Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(font_val, draw_x + 30, draw_y + multiplier, v.last_hit .. "/" .. v.denied, 0)
        Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawImage(v.icon, draw_x, draw_y + multiplier, 25, 25)
        multiplier = multiplier + 28
    end
end

function lhtracker.sortByLh()
    Config.WriteFile("lhtracker.json", JSON.Encode(player_track))
    arr = {}
    for i in pairs(player_track) do
        table.insert(arr, {last_hit = player_track[i].last_hit, icon = player_track[i].icon, denied = player_track[i].denied, team = player_track[i].team})
    end
    table.sort (arr, function (a, b) return a.last_hit > b.last_hit end )
    return arr
end

return lhtracker