local butchers_apron_id = Isaac.GetItemIdByName("Butcher's Apron")

local butchers_apron = {
  id_table = { butchers_apron_id }
}

function butchers_apron.stage(data)
  data.butchers = {}
end

function butchers_apron.initalize_player(data, player)
  local tag = support.tag(player)

  data.butchers[tag] = {
    skill = 1,
    blood = 0,
    total = 0,
    damage = 0.5,
  }
end

function butchers_apron.evaluate_cache(data, player, flag)
  if flag ~= CacheFlag.CACHE_DAMAGE then
    return
  end

  if not player:HasCollectible(butchers_apron_id) then
    return
  end

  local tag = support.tag(player)

  player.Damage = player.Damage + data.butchers[tag].damage
end

function butchers_apron.entity_take_damage(data, entity, damage, flags, source)
  if not entity:IsEnemy() then
    return
  end

  local player = source.Entity:ToPlayer()

  if not player and source.Entity.Parent then
    player = source.Entity.Parent:ToPlayer()
  end

  if not player then
    return
  end

  if not player:HasCollectible(butchers_apron_id) then
    return
  end

  local tag = support.tag(player)

  data.butchers[tag].blood = data.butchers[tag].blood + (data.butchers[tag].skill * damage)
  data.butchers[tag].total = data.butchers[tag].total + damage

  local fortune = null

  if data.butchers[tag].total > 5000 then
    if data.butchers[tag].skill ~= 4 then
      data.butchers[tag].skill = 4
      fortune = "Butcher Grandmaster"
    end
  elseif data.butchers[tag].total > 2500 then
    if data.butchers[tag].skill ~= 3 then
      data.butchers[tag].skill = 3
      fortune = "Butcher Master"
    end
  elseif data.butchers[tag].total > 1250 then
    if data.butchers[tag].skill ~= 2 then
      data.butchers[tag].skill = 2
      fortune = "Butcher Journeyman"
    end
  else
    data.butchers[tag].skill = 1
  end

  if fortune ~= nil then
    local hud = Game():GetHUD()
    hud:ShowFortuneText(fortune)
    player:AnimateHappy()
  end

end

function butchers_apron.post_perfect_update(data, player)
  if not player:HasCollectible(butchers_apron_id) then
    return
  end

  local tag = support.tag(player)

  if data.butchers[tag].blood > 0 then
    data.butchers[tag].blood = data.butchers[tag].blood - 1
  end

  local damage = data.butchers[tag].damage

  if data.butchers[tag].blood > 100 then
    data.butchers[tag].damage = 1.5
  elseif data.butchers[tag].blood > 50 then
    data.butchers[tag].damage = 1.25
  elseif data.butchers[tag].blood > 25 then
    data.butchers[tag].damage = 1.0
  elseif data.butchers[tag].blood > 0 then
    data.butchers[tag].damage = 0.5
  end

  if damage ~= data.butchers[tag].damage then
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
  end

  if Random() % 100 < data.butchers[tag].blood then
    local offset = Vector.One:Rotated(Random() % 360) * (Random() % 10)
    local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, player.Position + offset, Vector.Zero, player)
    local effect = entity:ToEffect()
    effect.Scale = 0.5
  end
end
