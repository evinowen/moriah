local oven_mitt_id = Isaac.GetTrinketIdByName("Oven Mitt")

local oven_mitt = {
  id_table = { oven_mitt_id },
}

function oven_mitt.pre_player_collision(data, player, collider)
  if not player:HasTrinket(oven_mitt_id, true) then
    return
  end

  if collider.Type == EntityType.ENTITY_FIREPLACE then
    return true
  end
end


function oven_mitt.entity_take_damage(data, entity, amount, flags, source, countdown)
  local player = entity:ToPlayer()

  if not player then
    return
  end

  if not player:HasTrinket(oven_mitt_id, true) then
    return
  end

  if source.Type == EntityType.ENTITY_FIREPLACE then
    return false
  end
end
