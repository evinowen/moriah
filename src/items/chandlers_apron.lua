local chandlers_apron_id = Isaac.GetItemIdByName("Chandler's Apron")

local chandlers_apron = {
  id_table = { chandlers_apron_id },
  wax_charge_ratio = 100,
  puddle_scale_ratio = 1 / 6.0,
  drip_chance_ratio = 3,
  drip_size_ratio = 0.03,
}

function chandlers_apron.stage(data)
  data.chandlers = {}
end

function chandlers_apron.initalize_player(data, player)
  local tag = support.tag(player)

  data.chandlers[tag] = {
    skill = 1,
    wax = 0,
    total = 0,
    shot_speed = 0,
    active_primary = 0,
    charge_primary = 0,
    active_secondary = 0,
    charge_secondary = 0,
    scale = 0,
    puddle = nil,
  }
end

function chandlers_apron.reset_player(data, player)
  local tag = support.tag(player)

  data.chandlers[tag].scale = 0
  data.chandlers[tag].puddle = nil
end

function chandlers_apron.evaluate_cache(data, player, flag)
  if flag ~= CacheFlag.CACHE_SHOTSPEED then
    return
  end

  if not player:HasCollectible(chandlers_apron_id) then
    return
  end

  local tag = support.tag(player)

  player.ShotSpeed = player.ShotSpeed + data.chandlers[tag].shot_speed
end

function chandlers_apron.gain_wax(data, player)
  local tag = support.tag(player)

  local wax = 0

  local active_primary = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
  local charge_primary = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)
  if active_primary > 0 then

    if data.chandlers[tag].active_primary ~= active_primary then
      data.chandlers[tag].active_primary = active_primary
    elseif data.chandlers[tag].charge_primary < charge_primary then
      local item_config = Isaac.GetItemConfig():GetCollectible(active_primary)
      if item_config.ChargeType == 0 then
        local delta = charge_primary - data.chandlers[tag].charge_primary
        wax = wax + (delta * chandlers_apron.wax_charge_ratio)
      elseif item_config.ChargeType == 1 then
        if charge_primary == item_config.MaxCharges then
          wax = wax + chandlers_apron.wax_charge_ratio
        end
      end
    end

    data.chandlers[tag].charge_primary = charge_primary
  end

  local active_secondary = player:GetActiveItem(ActiveSlot.SLOT_SECONDARY)
  local charge_secondary = player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY) + player:GetBatteryCharge(ActiveSlot.SLOT_SECONDARY)
  if active_secondary > 0 then
    local item_config = Isaac.GetItemConfig():GetCollectible(active_secondary)

    if data.chandlers[tag].active_secondary ~= active_secondary then
      data.chandlers[tag].active_secondary = active_secondary
    elseif data.chandlers[tag].charge_secondary < charge_secondary then
      local item_config = Isaac.GetItemConfig():GetCollectible(active_secondary)
      if item_config.ChargeType == 0 then
        local delta = charge_secondary - data.chandlers[tag].charge_secondary
        wax = wax + (delta * chandlers_apron.wax_charge_ratio)
      elseif item_config.ChargeType == 1 then
        if charge_secondary == item_config.MaxCharges then
          wax = wax + chandlers_apron.wax_charge_ratio
        end
      end
    end

    data.chandlers[tag].charge_secondary = charge_secondary
  end

  if wax <= 0 then
    return
  end

  data.chandlers[tag].wax = data.chandlers[tag].wax + (data.chandlers[tag].skill * wax)
  data.chandlers[tag].total = data.chandlers[tag].total + wax

  local fortune = nil

  if data.chandlers[tag].total > 5000 then
    if data.chandlers[tag].skill ~= 4 then
      data.chandlers[tag].skill = 4
      fortune = "Chandler Grandmaster"
    end
  elseif data.chandlers[tag].total > 2500 then
    if data.chandlers[tag].skill ~= 3 then
      data.chandlers[tag].skill = 3
      fortune = "Chandler Master"
    end
  elseif data.chandlers[tag].total > 1250 then
    if data.chandlers[tag].skill ~= 2 then
      data.chandlers[tag].skill = 2
      fortune = "Chandler Journeyman"
    end
  else
    data.chandlers[tag].skill = 1
  end

  if fortune ~= nil then
    local hud = Game():GetHUD()
    hud:ShowFortuneText(fortune)
    player:AnimateHappy()
  end
end

function chandlers_apron.post_perfect_update(data, player)
  if not player:HasCollectible(chandlers_apron_id) then
    return
  end

  local tag = support.tag(player)

  chandlers_apron.gain_wax(data, player)

  local shot_speed = data.chandlers[tag].shot_speed

  if data.chandlers[tag].wax > 100 then
    data.chandlers[tag].shot_speed = 1.5
  elseif data.chandlers[tag].wax > 50 then
    data.chandlers[tag].shot_speed = 1.25
  elseif data.chandlers[tag].wax > 25 then
    data.chandlers[tag].shot_speed = 1.0
  elseif data.chandlers[tag].wax > 0 then
    data.chandlers[tag].shot_speed = 0.5
  end

  if shot_speed ~= data.chandlers[tag].shot_speed then
    player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
    player:EvaluateItems()
  end

  if data.chandlers[tag].wax <= 0 then
    return
  end

  local no_player_input = player:GetMovementDirection() == Direction.NO_DIRECTION
  local still = player.Velocity:Length() < 0.01

  if still and no_player_input then
    data.chandlers[tag].wax = data.chandlers[tag].wax - 1

    if data.chandlers[tag].puddle == nil then
      local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_LEMON_PARTY, 0, player.Position, Vector.Zero, player)

      data.chandlers[tag].puddle = entity:ToEffect()
      data.chandlers[tag].puddle:SetColor(Color(1, 1, 1, 1, 0.8, 0.8, 0.8), -1, 1, false, false)
      data.chandlers[tag].scale = 0.01

      local sprite = data.chandlers[tag].puddle:GetSprite()
      sprite.Scale = Vector(0, 0)
    end

    data.chandlers[tag].scale = data.chandlers[tag].scale + 0.0025
    if data.chandlers[tag].scale > (data.chandlers[tag].skill * chandlers_apron.puddle_scale_ratio) then
      data.chandlers[tag].scale = data.chandlers[tag].skill  * chandlers_apron.puddle_scale_ratio
    end

    data.chandlers[tag].puddle.Scale = data.chandlers[tag].scale
    data.chandlers[tag].puddle.Timeout = 125
  else
    data.chandlers[tag].puddle = nil

    if Random() % 100 < (data.chandlers[tag].skill  * chandlers_apron.drip_chance_ratio) then
      data.chandlers[tag].wax = data.chandlers[tag].wax - 1

      local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_LEMON_PARTY, 0, player.Position, Vector.Zero, player)
      local effect = entity:ToEffect()
      local sprite = effect:GetSprite()
      sprite.Scale = Vector(0, 0)

      effect:SetColor(Color(1, 1, 1, 1, 0.8, 0.8, 0.8), -1, 1, false, false)
      effect.Scale = data.chandlers[tag].skill  * chandlers_apron.drip_size_ratio
    end
  end
end
