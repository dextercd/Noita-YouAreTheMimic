ModLuaFileAppend("data/scripts/perks/perk_list.lua", "data/YouAreTheMimic/perk_tweaks.lua")

local player
local frames_holding_movement_keys = 0
local is_wand = false

function is_wand()
    return GameHasFlagRun("YouAreTheMimic_is_wand")
end

function set_is_wand()
    GameAddFlagRun("YouAreTheMimic_is_wand")
end

local MOVEMENT_KEY_FIELDS = {
    "mButtonDownLeft",
    "mButtonDownRight",
    "mButtonDownUp"
}

function OnPlayerSpawned(player_entity)
    player = player_entity
end

function OnWorldPreUpdate()
    if not player or not EntityGetIsAlive(player) then
        player = EntityGetWithTag("player_unit")[1]
        if not EntityGetIsAlive(player) then
            return
        end
    end

    if not is_wand() then
        local controls_comp = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")

        for _, movement_key_field in ipairs(MOVEMENT_KEY_FIELDS) do
            if ComponentGetValue2(controls_comp, movement_key_field) then
                frames_holding_movement_keys = frames_holding_movement_keys + 1
                break
            end
        end

        if frames_holding_movement_keys == 2.6 * 60 then
            wand_escape()
        end
    end

    if is_wand() then
        local damage_comp = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
        local liquid_count = ComponentGetValue2(damage_comp, "mLiquidCount")
        enable_flight(liquid_count > 10)
    end
end

local function copy_component_enabled(to, from, component_type, tag)
    local enabled = EntityGetFirstComponentIncludingDisabled(from, component_type, tag) ~= nil

    local candidates = EntityGetComponentIncludingDisabled(to, component_type)
    for _, comp in ipairs(candidates) do
        if ComponentHasTag(comp, tag) then
            EntitySetComponentIsEnabled(to, comp, enabled)
        end
    end
end


function wand_escape()
    set_is_wand()


    local x, y = EntityGetTransform(player)
    EntityApplyTransform(player, x, y - 7)
    local chaser = EntityLoad("data/YouAreTheMimic/chaser.xml", x, y)

    copy_component_enabled(chaser, player, "SpriteComponent", "player_amulet")
    copy_component_enabled(chaser, player, "SpriteComponent", "player_amulet_gem")
    copy_component_enabled(chaser, player, "SpriteComponent", "player_hat")
    copy_component_enabled(chaser, player, "SpriteComponent", "player_hat2")
    copy_component_enabled(chaser, player, "SpriteComponent", "player_hat2_shadow")

    remove_all_comps(player, "SpriteComponent")
    remove_all_comps(player, "SpriteStainsComponent")
    remove_all_comps(player, "ParticleEmitterComponent")
    remove_all_comps(player, "SpriteParticleEmitterComponent")
    remove_all_comps(player, "HitboxComponent", "crouched")
    remove_all_comps(player, "AudioLoopComponent", "sound_jetpack")

    local chardat_comp = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
    ComponentSetValue2(chardat_comp, "climb_over_y", 3)
    ComponentSetValue2(chardat_comp, "flying_needs_recharge", false) -- Hide charge bar
    enable_flight(false)

    local charplat_comp = EntityGetFirstComponentIncludingDisabled(player, "CharacterPlatformingComponent")
    ComponentSetValue2(charplat_comp, "jump_velocity_y", -120) -- So player can enter portals by jumping

    local damage_comp = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
    ComponentSetValue2(damage_comp, "ragdoll_filenames_file", "data/ragdolls/duck/filenames.txt") -- idk dude

    local hitbox = EntityGetFirstComponentIncludingDisabled(player, "HitboxComponent")
    ComponentSetValue2(hitbox, "aabb_min_y", -4.8)

    for _, child in ipairs(EntityGetAllChildren(player)) do
        local name = EntityGetName(child)
        if name == "cape" or name == "arm_r" then
            EntityKill(child)
        end
    end

    EntityAddComponent2(player, "SpriteComponent", {
        _tags="character",
        image_file = "data/YouAreTheMimic/sprite.xml",
        alpha = 1,
        z_index = 0.6,
    })
    EntityAddComponent2(player, "SpriteStainsComponent")
end

function enable_flight(enable)
    local charplat_comp = EntityGetFirstComponentIncludingDisabled(player, "CharacterPlatformingComponent")
    ComponentSetValue2(charplat_comp, "fly_speed_change_spd", enable and 0.25 or 0)
end

function remove_all_comps(entity_id, comp_type, tag)
    local comps
    if tag and tag ~= "" then
        comps = EntityGetComponentIncludingDisabled(entity_id, comp_type, tag)
    else
        comps = EntityGetComponentIncludingDisabled(entity_id, comp_type)
    end

    if not comps then
        return
    end

    for _, comp in ipairs(comps) do
        EntityRemoveComponent(entity_id, comp)
    end
end
