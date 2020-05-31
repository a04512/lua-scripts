local p = {
    OptionEnable = Menu.AddOption({"typocant", "Projectile Dodger"}, "1. Enable", "Enable/Disable this script."),
    bkbAegis = Menu.AddOption({"typocant", "Projectile Dodger"}, "2. BKB with Aegis", "Use Black king bar with aegis"),
}

local active_tracking = {}
local dangerProjectiles = {}
local delay = 0

function p.OnScriptLoad()
    active_tracking = {}
    p.init()
end

function p.OnProjectile(projectile)
    if Menu.IsEnabled(p.OptionEnable) == false then return end
    if not myHero then return end
    if projectile.target == myHero then
        table.insert(active_tracking, {handle = projectile.handle, name = projectile.name})
    end
end

function p.OnProjectileLoc(projectile)
    if Menu.IsEnabled(p.OptionEnable) == false then return end
    if not myHero then return end
    if projectile.target == myHero then
        table.insert(active_tracking, {handle = projectile.handle, name = projectile.name})
    end
end

function p.OnDraw()
    if Menu.IsEnabled(p.OptionEnable) == false then return end
    myHero = Heroes.GetLocal()
    if not myHero then return end
    for i in ipairs(active_tracking) do
        local handle = active_tracking[i].handle
        local projectileName = active_tracking[i].name
        local projectile = Projectiles.GetTrackingProjectileByHandle(handle)
        if dangerProjectiles[projectileName] then
            if projectile then
                local distance_to_unit = (Entity.GetAbsOrigin(myHero) - projectile.position):Length2D()
                local item = p.findItem(dangerProjectiles[projectileName].items)
                if item then
                    Log.Write(item.time)
                    if item.time ~= 0 then
                        distance_to_unit = distance_to_unit - ((item.time * 2) * projectile.speed)
                    end
                    if distance_to_unit < (NPC.GetHullRadius(myHero) * 10) then
                        if (NPC.IsLinkensProtected(myHero) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) or NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE)) then table.remove(active_tracking, i) return end
                        if delay < os.clock() then 
                            if p.useItem(item) then table.remove(active_tracking, i) return end 
                        end
                    end
                end
            end
        end
        if projectile == nil then
            table.remove(active_tracking, i)
        end
    end
end

function p.findItem(items)
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_MUTED) then return end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_STUNNED) then return end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) then return end
    for i in ipairs(items) do
        local item = items[i]
        if item.name == "item_black_king_bar" then
            if NPC.HasItem(myHero, "item_aegis", true) then
                if Menu.IsEnabled(p.bkbAegis) == false then goto continue end
            end
        end
        if item.isItem then
            itemO = NPC.GetItem(myHero, item.name, true)
        else
            if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_SILENCED) then goto continue end
            itemO = NPC.GetAbility(myHero, item.name)
        end
        if itemO and Ability.GetLevel(itemO) > 0 and Ability.IsReady(itemO) then
            if item.name == "phantom_assassin_blur" then
                if NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
                    item.time = 0
                end
            end
            if item.name == "ursa_enrage" then
                if NPC.HasItem(myHero, "item_ultimate_scepter", true) or NPC.HasModifier(myHero, "modifier_item_ultimate_scepter_consumed") then
                    goto continue
                end
            end
            return {type = item.type, Obj = itemO, time = item.time, name = item.name}
        end
        ::continue::
    end
end

function p.useItem(item)
    if item.type == 0 then
        Ability.CastNoTarget(item.Obj)
        delay = os.clock() + 0.5
        return true
    elseif item.type == 1 then
        Ability.CastTarget(item.Obj, myHero)
        delay = os.clock() + 0.5
        return true
    end
end

function p.init()
    dangerProjectiles['sven_spell_storm_bolt'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['sniper_assassinate'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0},  
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['sniper_assassinate_charlie'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['chaos_knight_chaos_bolt'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['brewmaster_hurl_boulder'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['alchemist_unstable_concoction_projectile'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['windrunner_shackleshot'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['wr_ti8_shackleshot'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['morphling_adaptive_strike_agi_proj'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['morphling_adaptive_strike_str_proj'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['templar_assassin_meld_focal_attack'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="necrolyte_sadist",isItem=false,type=0,time=0},
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_ghost",isItem=true,type=0,time=0},
            {name="item_ethereal_blade",isItem=true,type=1,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['templar_assassin_meld_attack'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="necrolyte_sadist",isItem=false,type=0,time=0},
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_ghost",isItem=true,type=0,time=0},
            {name="item_ethereal_blade",isItem=true,type=1,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['vs_ti8_immortal_magic_missle_crimson'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['vs_ti8_immortal_magic_missle'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['vengeful_magic_missle'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['wraith_king_ti6_hellfireblast'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['wk_arc_wraithfireblast'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['skeletonking_hellfireblast'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['dragon_knight_dragon_tail_dragonform_proj'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_cyclone",isItem=true,type=1,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['rod_of_atos_attack'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
        }
    }
    dangerProjectiles['nullifier_proj'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_black_king_bar",isItem=true,type=0,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
    dangerProjectiles['siren_net_projectile'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
        }
    }
    dangerProjectiles['ethereal_blade'] = {
        items = {
            {name="void_spirit_dissimilate",isItem=false,type=0,time=0.2},
            {name="phantom_assassin_blur",isItem=false,type=0,time=0.4},
            {name="juggernaut_blade_fury",isItem=false,type=0,time=0}, 
            {name="slark_dark_pact",isItem=false,type=0,time=0.5}, 
            {name="puck_phase_shift",isItem=false,type=0,time=0}, 
            {name="ursa_enrage",isItem=false,type=0,time=0},
            {name="life_stealer_rage",isItem=false,type=0,time=0},
            {name="spirit_breaker_bulldoze",isItem=false,type=0,time=0}, 
            {name="omniknight_repel",isItem=false,type=1,time=0.25},
            {name="antimage_counterspell",isItem=false,type=0,time=0},
            {name="item_flicker",isItem=true,type=0,time=0},
            {name="item_minotaur_horn",isItem=true,type=0,time=0},
            {name="item_manta",isItem=true,type=0,time=0},
            {name="item_lotus_orb",isItem=true,type=1,time=0},
            {name="item_blade_mail",isItem=true,type=0,time=0},
            {name="item_glimmer_cape",isItem=true,type=1,time=0},
            {name="item_hood_of_defiance",isItem=true,type=0,time=0},
            {name="item_pipe",isItem=true,type=0,time=0}, 
            {name="slark_shadow_dance",isItem=false,type=0,time=0},
        }
    }
end

return p