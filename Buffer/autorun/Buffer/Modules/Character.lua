local utils, config, language
local data = {
    title = "character",
    unlimited_stamina = false,
    health = {
        healing = false,
        insta_healing = false,
        max_dragonheart = false,
        max_heroics = false,
        max_adrenaline = false
    },
    conditions_and_blights = {
        blights = {
            fire = false,
            water = false,
            ice = false,
            thunder = false,
            dragon = false,
            bubble = false,
            blast = false
        },
        conditions = {
            bleeding = false,
            stun = false,
            poison = false,
            sleep = false,
            frenzy = false,
            qurio = false,
            defence_and_resistance = false,
            hellfire_and_stentch = false,
            paralyze = false,
            thread = false
        }
    },
    stats = {
        attack = -1,
        defence = -1,
        affinity = -1
    },
    original = { }
}

function data.init()
    utils = require("Buffer.Misc.Utils")
    config = require("Buffer.Misc.Config")
    language = require("Buffer.Misc.Language")

    data.init_hooks()
end

function data.init_hooks()
    sdk.hook(sdk.find_type_definition("snow.player.PlayerManager"):get_method("update"), function(args)

        local playerBase = utils.getPlayerBase()
        if not playerBase then return end
        local playerData = utils.getPlayerData()
        if not playerData then return end

        if data.unlimited_stamina then
            local maxStamina = playerData:get_field("_staminaMax")
            playerData:set_field("_stamina", maxStamina)
        end

        if data.health.healing then
            local max = playerData:get_field("_vitalMax")
            playerData:set_field("_r_Vital", max)
        end

        if data.health.insta_healing then
            local max = playerData:get_field("_vitalMax")

            local maxFloat = max + .0
            playerData:set_field("_r_Vital", max)
            playerData:call("set__vital", maxFloat)
        end

        if data.health.max_dragonheart then
            local max = playerData:get_field("_vitalMax")
            local playerSkills = playerBase:call("get_PlayerSkillList")
            if playerSkills then
                local dhSkill = playerSkills:call("getSkillData", 103) -- Dragonheart Skill ID
                if dhSkill then
                    local dhLevel = dhSkill:get_field("SkillLv")

                    -- Depending on level set health percent
                    local newHealth = max
                    if dhLevel == 1 or dhLevel == 2 then newHealth = math.floor(max * 0.5) end
                    if dhLevel == 3 or dhLevel == 4 then newHealth = math.floor(max * 0.7) end
                    if dhLevel == 5 then newHealth = math.floor(max * 0.8) end

                    playerData:set_field("_r_Vital", math.min(max, newHealth) + .0)
                    playerData:call("set__vital", math.min(max, newHealth) + .0)
                end
            end
        end

        if data.health.max_heroics then
            local max = playerData:get_field("_vitalMax")
            local newHealth = math.floor(max * 0.35)

            playerData:set_field("_r_Vital", math.min(max, newHealth) + .0)
            playerData:call("set__vital", math.min(max, newHealth) + .0)
        end

        if data.health.max_adrenaline then
            local max = playerData:get_field("_vitalMax")
            local newHealth = 10.0

            playerData:set_field("_r_Vital", math.min(max, newHealth) + .0)
            playerData:call("set__vital", math.min(max, newHealth) + .0)
        end

        local is_in_lobby = playerBase:get_field("<IsLobbyPlayer>k__BackingField")

        if data.conditions_and_blights.blights.fire and not is_in_lobby then
            playerBase:set_field("_FireLDurationTimer", 0) -- The fire timer
            playerBase:set_field("_FireDamageTimer", 0) -- The fire damage timer
        end

        if data.conditions_and_blights.blights.water and not is_in_lobby then
            playerBase:set_field("_WaterLDurationTimer", 0) -- The water blight timer
        end

        if data.conditions_and_blights.blights.ice and not is_in_lobby then
            playerBase:set_field("_IceLDurationTimer", 0) -- The ice blight timer
        end

        if data.conditions_and_blights.blights.thunder and not is_in_lobby then
            playerBase:set_field("_ThunderLDurationTimer", 0) -- The thunder blight timer
        end

        if data.conditions_and_blights.blights.dragon and not is_in_lobby then
            playerBase:set_field("_DragonLDurationTimer", 0) -- The dragon blight timer
        end

        if data.conditions_and_blights.blights.bubble and not is_in_lobby then
            playerBase:set_field("_BubbleDamageTimer", 0) -- The bubble timer
            -- playerData:set_field("_BubbleType", 0) -- | 0=None | 1=BubbleS | 2=BubbleL |
        end

        if data.conditions_and_blights.blights.blast and not is_in_lobby then
            playerBase:set_field("_BombDurationTimer", 0) -- The blast timer
        end

        if data.conditions_and_blights.conditions.bleeding and not is_in_lobby then
            playerBase:set_field("_BleedingDebuffTimer", 0) -- The bleeding timer
        end

        if data.conditions_and_blights.conditions.poison and not is_in_lobby then
            playerBase:set_field("_PoisonDurationTimer", 0) -- The poison timer
            playerBase:set_field("_PoisonDamageTimer", 0) -- How long till next poison tick
            -- playerData:set_field("_PoisonLv", 0) -- | 0=None | 1=Poison | 2=NoxiousPoison | 3=DeadlyPoison | 
        end

        if data.conditions_and_blights.conditions.stun and not is_in_lobby then
            playerBase:set_field("_StunDurationTimer", 0) -- The stun timer -- DOESN'T REMOVE ANIMATION TIME
        end

        if data.conditions_and_blights.conditions.sleep and not is_in_lobby then
            playerBase:set_field("_SleepDurationTimer", 0) -- The sleep timer
            playerBase:set_field("<SleepMovableTimer>k__BackingField", 0) -- The sleep walking timer
        end

        if data.conditions_and_blights.conditions.paralyze and not is_in_lobby then
            playerBase:set_field("_ParalyzeDurationTimer", 0) -- The paralysis recovery timer -- DOESN'T REMOVE ANIMATION TIME
        end

        if data.conditions_and_blights.conditions.frenzy and not is_in_lobby then
            playerBase:set_field("_IsVirusLatency", false) -- The frenzy virus
            playerBase:set_field("_VirusTimer", 0) -- How long till the next frenzy virus tick
            playerBase:set_field("_VirusAccumulator", 0) -- Total ticks of Frenzy
        end

        if data.conditions_and_blights.conditions.qurio and not is_in_lobby then
            playerBase:set_field("_MysteryDebuffTimer", 0) -- The qurio timer
            playerBase:set_field("_MysteryDebuffDamageTimer", 0) -- The qurio damage timer")
        end

        if data.conditions_and_blights.conditions.defence_and_resistance and not is_in_lobby then
            playerBase:set_field("_ResistanceDownDurationTimer", 0) -- The resistance down timer
            playerBase:set_field("_DefenceDownDurationTimer", 0) -- The defence down timer
        end

        if data.conditions_and_blights.conditions.hellfire_and_stentch and not is_in_lobby then
            playerBase:set_field("_OniBombDurationTimer", 0) -- The hellfire timer
            playerBase:set_field("_StinkDurationTimer", 0) -- The putrid gas damage timer
        end
        if data.conditions_and_blights.conditions.thread and not is_in_lobby then
            playerBase:set_field("_BetoDurationTimer", 0) -- The covered in spider web recovery timer -- DOESN'T REMOVE ANIMATION TIME
        end

        if data.stats.attack > -1 then
            -- Set the original attack value
            if data.original.attack == nil then data.original.attack = playerData:get_field("_Attack") end

            -- Setup variables to determine how much extra attack needs to be added to get to the set value
            local attack = data.original.attack
            local attackTarget = data.stats.attack
            local attackMod = attackTarget - attack

            -- Add the extra attack
            playerData:set_field("_AtkUpAlive", attackMod)

            -- Restore the original attack value if disabled    
        elseif data.original.attack ~= nil then
            playerData:set_field("_AtkUpAlive", 0)
            data.original.attack = nil
        end

        if data.stats.defence > -1 then
            -- Set the original defence value
            if data.original.defence == nil then data.original.defence = playerData:get_field("_Defence") end

            -- Setup variables to determine how much extra defence needs to be added to get to the set value
            local defence = data.original.defence
            local defenceTarget = data.stats.defence
            local defenceMod = defenceTarget - defence

            -- Add the extra defence
            playerData:set_field("_DefUpAlive", defenceMod)
               -- Restore the original defence value if disabled    
        elseif data.original.defence ~= nil then
            playerData:set_field("_DefUpAlive", 0)
            data.original.defence = nil
        end
    end)
    utils.nothing()

    -- local managed_atk = nil
    -- sdk.hook(sdk.find_type_definition("snow.equip.MainWeaponBaseData"):get_method("get_Atk"), function(args)
    --     local managed = sdk.to_managed_object(args[2])
    --     if not managed then return end
    --     if not managed:get_type_definition():is_a("snow.equip.MainWeaponBaseData") then return end
    --     managed_atk = managed
    -- end, function(retval)
    --     if managed_atk ~= nil then
    --         if data.stats.attack > -1 then
    --             if data.original.attack == nil then data.original.attack = utils.getPlayerData():get_field("_Attack") end
    --             local player = data.original.attack
    --             local weapon = managed_atk:get_field("_Atk")
    --             local target = data.stats.attack
    --             local to_set = target - player + weapon

                
    --             log.debug("Target: "..data.stats.attack)
    --             log.debug("Player Original: ".. data.original.attack)
    --             log.debug("Weapon: ".. weapon)
    --             log.debug("Value to set: "..to_set )
    --             log.debug("--------------------------------------")
    --             managed_atk = nil
    --             return sdk.to_ptr(data.stats.attack)
    --         else if data.original.attack ~= nil then data.original.attack = nil end
    --     end
    --     managed_atk = nil
    -- end
    -- return retval
    -- end)

    -- local managed_def = nil
    -- sdk.hook(sdk.find_type_definition("snow.equip.MainWeaponBaseData"):get_method("get_DefBonus"), function(args)
    --     local managed = sdk.to_managed_object(args[2])
    --     if not managed then return end
    --     if not managed:get_type_definition():is_a("snow.equip.MainWeaponBaseData") then return end
    --     managed_def = managed
    -- end, function(retval)
    --     if managed_def ~= nil then
    --         if data.stats.defence > -1 then
    --             if data.original.defence == nil then data.original.defence = utils.getPlayerData():get_field("_Defence") end
    --             local player = data.original.defence
    --             local weapon = managed_def:get_field("_DefBonus")
    --             local target = data.stats.defence
    --             local to_set = target - player + weapon
    --             managed_def = nil
    --             return sdk.to_ptr(to_set)
    --         else if data.original.defence ~= nil then data.original.defence = nil end
    --         end
    --         managed_def = nil
    --     end
    --     return retval
    -- end)

    local managed_crit = nil
    -- snow.player.HeavyBowgun > RefWeaponData > > > LocalBaseData > > > _WeaponBaseData
    sdk.hook(sdk.find_type_definition("snow.equip.MainWeaponBaseData"):get_method("get_CriticalRate"), function(args)
        local managed = sdk.to_managed_object(args[2])
        if not managed then return end
        if not managed:get_type_definition():is_a("snow.equip.MainWeaponBaseData") then return end
        managed_crit = managed
    end, function(retval)
        if managed_crit ~= nil then
            if data.stats.affinity > -1 then
                if data.original.affinity == nil then data.original.affinity = utils.getPlayerData():get_field("_CriticalRate") end
                local player = data.original.affinity
                local weapon = managed_crit:get_field("_CriticalRate")
                local target = data.stats.affinity
                local to_set = target - player + weapon 
                managed_crit = nil
                return sdk.to_ptr(to_set)
            else if data.original.affinity ~= nil then data.original.affinity = nil end
        end
        managed_crit = nil
    end
    return retval
    end)
end

function data.draw()

    local changed, any_changed = false, false
    local languagePrefix = data.title .. "."
    if imgui.collapsing_header(language.get(languagePrefix .. "title")) then
        imgui.indent(10)

        changed, data.unlimited_stamina = imgui.checkbox(language.get(languagePrefix .. "unlimited_stamina"), data.unlimited_stamina)
        any_changed = any_changed or changed

        languagePrefix = data.title .. ".health."
        if imgui.tree_node(language.get(languagePrefix .. "title")) then
            changed, data.health.healing = imgui.checkbox(language.get(languagePrefix .. "healing"), data.health.healing)
            any_changed = any_changed or changed
            utils.tooltip(language.get(languagePrefix .. "healing_tooltip"))
            changed, data.health.insta_healing = imgui.checkbox(language.get(languagePrefix .. "insta_healing"), data.health.insta_healing)
            any_changed = any_changed or changed
            utils.tooltip(language.get(languagePrefix .. "insta_healing_tooltip"))
            changed, data.health.max_dragonheart = imgui.checkbox(language.get(languagePrefix .. "max_dragonheart"), data.health.max_dragonheart)
            any_changed = any_changed or changed
            utils.tooltip(language.get(languagePrefix .. "max_dragonheart_tooltip"))
            changed, data.health.max_heroics = imgui.checkbox(language.get(languagePrefix .. "max_heroics"), data.health.max_heroics)
            any_changed = any_changed or changed
            changed, data.health.max_adrenaline = imgui.checkbox(language.get(languagePrefix .. "max_adrenaline"), data.health.max_adrenaline)
            any_changed = any_changed or changed
            imgui.tree_pop()
        end
        languagePrefix = data.title .. ".conditions_and_blights."
        if imgui.tree_node(language.get(languagePrefix .. "title")) then

            languagePrefix = data.title .. ".conditions_and_blights.blights."
            if imgui.tree_node(language.get(languagePrefix .. "title")) then
                changed, data.conditions_and_blights.blights.fire = imgui.checkbox(language.get(languagePrefix .. "fire"), data.conditions_and_blights.blights.fire)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.blights.water = imgui.checkbox(language.get(languagePrefix .. "water"), data.conditions_and_blights.blights.water)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.blights.ice = imgui.checkbox(language.get(languagePrefix .. "ice"), data.conditions_and_blights.blights.ice)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.blights.thunder = imgui.checkbox(language.get(languagePrefix .. "thunder"), data.conditions_and_blights.blights.thunder)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.blights.dragon = imgui.checkbox(language.get(languagePrefix .. "dragon"), data.conditions_and_blights.blights.dragon)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.blights.bubble = imgui.checkbox(language.get(languagePrefix .. "bubble"), data.conditions_and_blights.blights.bubble)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.blights.blast = imgui.checkbox(language.get(languagePrefix .. "blast"), data.conditions_and_blights.blights.blast)
                any_changed = any_changed or changed
                imgui.tree_pop()
            end
            languagePrefix = data.title .. ".conditions_and_blights.conditions."
            if imgui.tree_node(language.get(languagePrefix .. "title")) then
                changed, data.conditions_and_blights.conditions.bleeding = imgui.checkbox(language.get(languagePrefix .. "bleeding"),
                                                                                          data.conditions_and_blights.conditions.bleeding)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.stun = imgui.checkbox(language.get(languagePrefix .. "stun"), data.conditions_and_blights.conditions.stun)
                utils.tooltip(language.get(languagePrefix .. "stun_tooltip"))
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.poison = imgui.checkbox(language.get(languagePrefix .. "poison"), data.conditions_and_blights.conditions.poison)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.sleep = imgui.checkbox(language.get(languagePrefix .. "sleep"), data.conditions_and_blights.conditions.sleep)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.frenzy = imgui.checkbox(language.get(languagePrefix .. "frenzy"), data.conditions_and_blights.conditions.frenzy)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.qurio = imgui.checkbox(language.get(languagePrefix .. "qurio"), data.conditions_and_blights.conditions.qurio)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.defence_and_resistance = imgui.checkbox(language.get(languagePrefix .. "defence_and_resistance"),
                                                                                                        data.conditions_and_blights.conditions.defence_and_resistance)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.hellfire_and_stentch = imgui.checkbox(language.get(languagePrefix .. "hellfire_and_stentch"),
                                                                                                      data.conditions_and_blights.conditions.hellfire_and_stentch)
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.paralyze = imgui.checkbox(language.get(languagePrefix .. "paralyze"),
                                                                                          data.conditions_and_blights.conditions.paralyze)
                utils.tooltip(language.get(languagePrefix .. "paralyze_tooltip"))
                any_changed = any_changed or changed
                changed, data.conditions_and_blights.conditions.thread = imgui.checkbox(language.get(languagePrefix .. "thread"), data.conditions_and_blights.conditions.thread)
                utils.tooltip(language.get(languagePrefix .. "thread_tooltip"))
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        languagePrefix = data.title .. ".stats."
        if imgui.tree_node(language.get(languagePrefix .. "title")) then
            local step = 10
            local attack_max, defence_max = 2600, 3100
            local stepped_attack_max, stepped_defence_max = math.floor(attack_max / step), math.floor(defence_max / step)
            local stepped_attack_value, stepped_defence_value = -1, -1
            if data.stats.attack > -1 then stepped_attack_value = math.floor(data.stats.attack / step) end
            if data.stats.defence > -1 then stepped_defence_value = math.floor(data.stats.defence / step) end
            local attack_slider, defence_slider
            changed, attack_slider = imgui.slider_int(language.get(languagePrefix .. "attack"), stepped_attack_value, -1, stepped_attack_max,
                                                      stepped_attack_value > -1 and stepped_attack_value * step or language.get(languagePrefix .. "attack_disabled"))
            any_changed = any_changed or changed
            utils.tooltip(language.get(languagePrefix .. "attack_tooltip"))
            changed, defence_slider = imgui.slider_int(language.get(languagePrefix .. "defence"), stepped_defence_value, -1, stepped_defence_max,
                                                       stepped_defence_value > -1 and stepped_defence_value * step or language.get(languagePrefix .. "attack_disabled"))
            any_changed = any_changed or changed
            utils.tooltip(language.get(languagePrefix .. "defence_tooltip"))
            data.stats.attack = attack_slider > -1 and attack_slider * step or -1
            data.stats.defence = defence_slider > -1 and defence_slider * step or -1

            changed, data.stats.affinity = imgui.slider_int(language.get(languagePrefix .. "affinity"), data.stats.affinity, -1, 100,
                                                            data.stats.affinity > -1 and " %d" .. '%%' or language.get(languagePrefix .. "affinity_disabled"))
            utils.tooltip(language.get(languagePrefix .. "affinity_tooltip"))
            any_changed = any_changed or changed
            imgui.tree_pop()
        end

        if any_changed then config.save_section(data.create_config_section()) end
        imgui.unindent(10)
        imgui.separator()
        imgui.spacing()
    end
end

function data.reset()
    -- Until I find a better way of increase attack, I have to reset this on script reset
    if data.stats.attack > -1 then
        local playerData = utils.getPlayerData()
        if not playerData then return end
        playerData:set_field("_AtkUpAlive", 0)
    end

    -- Until I find a better way of increase defence, I have to reset this on script reset
    if data.stats.defence > -1 then
        local playerData = utils.getPlayerData()
        if not playerData then return end
        playerData:set_field("_DefUpAlive", 0)
    end
end

function data.create_config_section()
    return {
        [data.title] = {
            unlimited_stamina = data.unlimited_stamina,
            health = {
                healing = data.health.healing,
                insta_healing = data.health.insta_healing,
                max_dragonheart = data.health.max_dragonheart,
                max_heroics = data.health.max_heroics,
                max_adrenaline = data.health.max_adrenaline
            },
            conditions_and_blights = {
                blights = {
                    fire = data.conditions_and_blights.blights.fire,
                    water = data.conditions_and_blights.blights.water,
                    ice = data.conditions_and_blights.blights.ice,
                    thunder = data.conditions_and_blights.blights.thunder,
                    dragon = data.conditions_and_blights.blights.dragon,
                    bubble = data.conditions_and_blights.blights.bubble,
                    blast = data.conditions_and_blights.blights.blast
                },
                conditions = {
                    bleeding = data.conditions_and_blights.conditions.bleeding,
                    poison = data.conditions_and_blights.conditions.poison,
                    sleep = data.conditions_and_blights.conditions.sleep,
                    paralyze = data.conditions_and_blights.conditions.paralyze,
                    frenzy = data.conditions_and_blights.conditions.frenzy,
                    qurio = data.conditions_and_blights.conditions.qurio,
                    defence_and_resistance = data.conditions_and_blights.conditions.defence_and_resistance,
                    hellfire_and_stentch = data.conditions_and_blights.conditions.hellfire_and_stentch,
                    stun = data.conditions_and_blights.conditions.stun,
                    thread = data.conditions_and_blights.conditions.thread
                }
            }
        }
    }
end

function data.load_from_config(config_section)
    if not config_section then return end

    data.unlimited_stamina = config_section.unlimited_stamina or data.unlimited_stamina
    data.health = config_section.health or data.health
    data.conditions_and_blights = config_section.conditions_and_blights or data.conditions_and_blights
end

return data
