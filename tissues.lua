local support = require("support")

local tissues_id = Isaac.GetTrinketIdByName("Tissues")

local tissues = {
  id_table = { tissues_id },
  tissue_throw_speed = 3,
  creep = {
    EffectVariant.CREEP_RED,
    EffectVariant.CREEP_GREEN,
    EffectVariant.CREEP_YELLOW,
    EffectVariant.CREEP_WHITE,
    EffectVariant.CREEP_BLACK,
    EffectVariant.PLAYER_CREEP_LEMON_MISHAP,
    EffectVariant.PLAYER_CREEP_HOLYWATER,
    EffectVariant.PLAYER_CREEP_WHITE,
    EffectVariant.PLAYER_CREEP_BLACK,
    EffectVariant.PLAYER_CREEP_RED,
    EffectVariant.PLAYER_CREEP_GREEN,
    EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL,
    EffectVariant.CREEP_BROWN,
    EffectVariant.PLAYER_CREEP_LEMON_PARTY,
    EffectVariant.PLAYER_CREEP_PUDDLE_MILK,
    EffectVariant.CREEP_SLIPPERY_BROWN,
    EffectVariant.CREEP_SLIPPERY_BROWN_GROWING,
    EffectVariant.CREEP_STATIC,
    EffectVariant.CREEP_LIQUID_POOP,
  }
}

function tissues.stage(data)
  data.tissues = {}
end

function tissues.initalize_player(data, player)
  local tag = support.tag(player)

  data.tissues[tag] = 0
end

function tissues.fire(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if player and player:HasTrinket(tissues_id, true) then
    tear:Remove()

    local tag = support.tag(player)
    data.tissues[tag] = data.tissues[tag] + 1

    if data.tissues[tag] >= 10 then
      local velocity = player.Velocity:Normalized() * -1 * tissues.tissue_throw_speed
      local tissue = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WOOD_PARTICLE, 1, player.Position, velocity, player)
      tissue:SetColor(Color(0.8, 0.8, 0.9, 1, 0.9, 0.9, 0.9), -1, 1, false, false)

      data.tissues[tag] = 0
    end
  end
end

function tissues.pre_player_collision(data, player, collider)
  local effect = collider:ToEffect()

  if not effect then
    return
  end

  support.print("tissues.pre_player_collision effect! "..effect.Variant)

  if support.contains(tissues.creep, effect.Variant) then
    local velocity = player.Velocity:Normalized() * -1 * tissues.tissue_throw_speed
    local tissue = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WOOD_PARTICLE, 1, player.Position, velocity, player)
    tissue:SetColor(effect:GetColor(), -1, 1, false, false)

    data.tissues[tag] = 0
    effect:Remove()
  end
end

return tissues
