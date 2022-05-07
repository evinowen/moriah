local support = require "support"

local helium_id = Isaac.GetItemIdByName("Helium")
local balloon_id = Isaac.GetEntityVariantByName("Helium Balloon")

local helium = {}

function helium.stage(data)
  support.print("helium stage")
  data.balloons = {}
  data.bouquets = {}
end

function helium.initalize_player(data, player)
  local tag = support.tag(player)

  support.print("helium "..tag.." init")
  data.balloons[tag] = 0
  data.bouquets[tag] = {}
end

function helium.use_item(data, item_id, _, player)
  if item_id ~= helium_id then
    return
  end

  local tag = support.tag(player)

  support.print("helium add balloon!")
  data.balloons[tag] = data.balloons[tag] + 1
  support.print("helium balloons == "..data.balloons[tag])

  player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
  player:AddCacheFlags(CacheFlag.CACHE_FLYING)
  player:AddCacheFlags(CacheFlag.CACHE_SPEED)
  player:EvaluateItems()
end

function helium.evaluate_cache(data, player, flag)
  local tag = support.tag(player)

  if flag == CacheFlag.CACHE_FAMILIARS then
    support.print("helium evaluate_cache balloons == "..data.balloons[tag])
    support.check_familiar(player, balloon_id, data.balloons[tag], helium_id)
  end

  if flag == CacheFlag.CACHE_FLYING then
    if data.balloons[tag] >= 3 then
      player.CanFly = true
    end
  end

  if flag == CacheFlag.CACHE_SPEED then
    if data.balloons[tag] >= 3 then
      player.MoveSpeed = player.MoveSpeed * 1.1
      player:MultiplyFriction(0.1)
    end
  end
end

function helium.familiar_init(data, familiar)
  if familiar.Variant ~= balloon_id then
    return
  end

  familiar.IsFollower = false
  familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

  local color = Color.Default

  local number = Random() % 6

  if number >= 5 then
    color:SetTint(1, 0, 0, 1)
  elseif number >= 4 then
    color:SetTint(0, 1, 0, 1)
  elseif number >= 3 then
    color:SetTint(0, 0, 1, 1)
  elseif number >= 2 then
    color:SetTint(1, 1, 0, 1)
  elseif number >= 1 then
    color:SetTint(0, 1, 1, 1)
  else
    color:SetTint(1, 0, 1, 1)
  end

  familiar:SetColor(color, -1, 1, false, false)
end

function helium.familiar_update(data, familiar)
  if familiar.Variant ~= balloon_id then
    return
  end

  local player = familiar.Player
  local tag = support.tag(player)
  local bouquet = data.bouquets[tag]

  local bouquet_key = "f".. familiar.InitSeed
  if bouquet[bouquet_key] == nil then
    local bouquet_index = 0
    for _, info in pairs(bouquet) do
      if bouquet_index < info.index then
        bouquet_index = info.index
      end
    end

    bouquet_index = bouquet_index + 1

    bouquet[bouquet_key] = {
      entity = familiar,
      index = bouquet_index,
      top = 1
    }

    for key, _ in pairs(data.bouquets[tag]) do
      support.print("key "..key)
      data.bouquets[tag][key].top = bouquet_index
    end
  end

  local position = player.Position
  local center = position


  local info = data.bouquets[tag][bouquet_key]

  if info.index > 1 then
    local rotated = Vector.One
    local distance = 12

    if info.index > 6 then
      local divisor = info.top - 6

      distance = distance * 2

      rotated = rotated:Rotated((360.0 / divisor) * (info.index - 7))
    else
      local divisor = info.top - 1
      if divisor > 6 then
        divisor = 6
      end

      rotated = rotated:Rotated((360.0 / divisor) * (info.index - 1))
    end


    position = center + (rotated * distance)
  end

  familiar:FollowPosition(position)

  local rotate = (familiar.Position - position).X
  local sprite = familiar:GetSprite()

  local clamp = 50

  if rotate > clamp then
    rotate = clamp
  elseif rotate < clamp * -1 then
    rotate = clamp * -1
  end

  local max = 15

  sprite.Rotation = (rotate / clamp) * max
end

function helium.entity_take_damage(data, damaged)
  local player = damaged:ToPlayer()

  if not player then
    return
  end

  local tag = support.tag(player)
  if data.balloons[tag] > 0 then
    data.balloons[tag] = data.balloons[tag] - 1

    local bouquet = data.bouquets[tag]
    local bouquet_key = nil
    local bouquet_entity = nil
    local bouquet_index = nil

    for key, info in pairs(bouquet) do
      if bouquet_index == nil or bouquet_index < info.index then
        bouquet_key = key
        bouquet_index = info.index
        bouquet_entity = info.entity
      end
    end

    data.bouquets[tag][bouquet_key] = nil

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, bouquet_entity.Position, Vector.Zero, bouquet_entity)

    for _ = 1, 10 do
      local effect_popped = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, Random() % 6, bouquet_entity.Position, Vector.One:Rotated((Random() % 360) * 24), bouquet_entity)
      effect_popped:SetColor(bouquet_entity:GetColor(), -1, 1, false, false)
    end

    bouquet_entity:Remove()

    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    player:EvaluateItems()

    player:SetMinDamageCooldown(15)
    return false
  end
end

return helium
