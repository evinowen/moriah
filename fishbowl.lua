local support = require "support"

local fishbowl_id = Isaac.GetItemIdByName("Fishbowl")

local fishbowl = {
  id_table = { fishbowl_id }
}

function fishbowl.evaluate_cache(data, player, flag)
  if flag == CacheFlag.CACHE_FLYING then
    if player:HasCollectible(fishbowl_id) then
      player.CanFly = true
    end
  end
end

function fishbowl.fire(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if player and player:HasCollectible(fishbowl_id) then
    local damage = tear.BaseDamage
    local color = tear:GetColor()
    tear:Remove()

    local puddle_entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, player.Position, Vector.Zero, player)
    local puddle_effect = puddle_entity:ToEffect()
    puddle_effect.Scale = damage / 5.0
    puddle_effect:SetColor(color, -1, 1, false, false)
  end
end

function fishbowl.pre_projectile_collision(data, projectile, collider)
  local player = collider:ToPlayer()

  if player and player:HasCollectible(fishbowl_id) then
    support.print('boing!')
    projectile.Velocity = projectile.Velocity * -0.9
    return true
  end
end

support.print("Loaded moriah.fishbowl")
return fishbowl
