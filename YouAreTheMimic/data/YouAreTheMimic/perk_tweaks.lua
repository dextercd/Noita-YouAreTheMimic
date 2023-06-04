for _, perk in ipairs(perk_list) do
    if perk.id == "HOVER_BOOST" then
        perk.func = function(entity_perk_item, entity_who_picked, item_name)
            if not EntityHasTag(entity_who_picked, "player_unit") then
                return
            end

            local charplat_comp = EntityGetFirstComponentIncludingDisabled(entity_who_picked, "CharacterPlatformingComponent")
            local jump_vel = ComponentGetValue2(charplat_comp, "jump_velocity_y")
            ComponentSetValue2(charplat_comp, "jump_velocity_y", jump_vel - 100)
        end
    end
end

for i=#perk_list,1,-1 do
    local id = perk_list[i].id
    if id == "FASTER_LEVITATION" then
        table.remove(perk_list, i)
    end
end
