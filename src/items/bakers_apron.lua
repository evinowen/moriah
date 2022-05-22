local bakers_apron_id = Isaac.GetItemIdByName("Baker's Apron")

local bakers_apron = {
  id_table = { bakers_apron_id },
  feed_distance = 6,
  feed_frames = 2,
}

function bakers_apron.stage(data)
  data.bakers = {}
end

function bakers_apron.initalize_player(data, player)
  local tag = support.tag(player)

  data.bakers[tag] = {
    skill = 1,
    flour = 0,
    total = 0,
    tears = 0.5,
    frame = 0,
    foot = false,
    healhcheck = 0
  }
end

function bakers_apron.evaluate_cache(data, player, flag)
  if flag ~= CacheFlag.CACHE_FIREDELAY then
    return
  end

  if not player:HasCollectible(bakers_apron_id) then
    return
  end

  local tag = support.tag(player)

  player.MaxFireDelay = player.MaxFireDelay + data.bakers[tag].tears
end

function bakers_apron.gain_flour(data, player)
  local tag = support.tag(player)
  local hearts = player:GetHearts()

  if data.bakers[tag].healhcheck == hearts then
    return
  end

  local difference = hearts - data.bakers[tag].healhcheck
  data.bakers[tag].healhcheck = hearts

  if difference < 1 then
    return
  end

  local flour = difference * 25

  data.bakers[tag].flour = data.bakers[tag].flour + (data.bakers[tag].skill * flour)
  data.bakers[tag].total = data.bakers[tag].total + flour

  local fortune = nil

  if data.bakers[tag].total > 5000 then
    if data.bakers[tag].skill ~= 4 then
      data.bakers[tag].skill = 4
      fortune = "Baker Grandmaster"
    end
  elseif data.bakers[tag].total > 2500 then
    if data.bakers[tag].skill ~= 3 then
      data.bakers[tag].skill = 3
      fortune = "Baker Master"
    end
  elseif data.bakers[tag].total > 1250 then
    if data.bakers[tag].skill ~= 2 then
      data.bakers[tag].skill = 2
      fortune = "Baker Journeyman"
    end
  else
    data.bakers[tag].skill = 1
  end

  if fortune ~= nil then
    local hud = Game():GetHUD()
    hud:ShowFortuneText(fortune)
    player:AnimateHappy()
  end
end

function bakers_apron.post_perfect_update(data, player)
  if not player:HasCollectible(bakers_apron_id) then
    return
  end

  local tag = support.tag(player)

  if data.bakers[tag].flour > 0 then
    data.bakers[tag].flour = data.bakers[tag].flour - 1
  end

  bakers_apron.gain_flour(data, player)

  local tears = data.bakers[tag].tears

  if data.bakers[tag].flour > 100 then
    data.bakers[tag].tears = 1.5
  elseif data.bakers[tag].flour > 50 then
    data.bakers[tag].tears = 1.25
  elseif data.bakers[tag].flour > 25 then
    data.bakers[tag].tears = 1.0
  elseif data.bakers[tag].flour > 0 then
    data.bakers[tag].tears = 0.5
  end

  if tears ~= data.bakers[tag].tears then
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems()
  end

  if player:GetMovementDirection() == Direction.NO_DIRECTION then
    return
  end

  if data.bakers[tag].flour > 0 then
    local offset = Vector.Zero
    if data.bakers[tag].food then
      data.bakers[tag].frame = data.bakers[tag].frame + 1
      if data.bakers[tag].frame < bakers_apron.feed_frames then
        return
      end

      data.bakers[tag].food = false
      offset = Vector.One * bakers_apron.feed_distance
    else
      data.bakers[tag].frame = data.bakers[tag].frame - 1
      if data.bakers[tag].frame > bakers_apron.feed_frames * -1 then
        return
      end

      data.bakers[tag].food = true
      offset = Vector.One * bakers_apron.feed_distance * -1
    end

    local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, player.Position + offset, Vector.Zero, player)
    local effect = entity:ToEffect()
    effect.Scale = 0.2
    effect:SetColor(Color(1, 1, 1, 1, 1, 1, 1), -1, 1, false, false)
  end
end
