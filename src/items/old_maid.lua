local old_maid_id = Isaac.GetCardIdByName("Old Maid")

local old_maid = {
  damage_per_cent = 5,
  nags = {
    "Oh, it reeks of taste!",
    "My turn to ring the bells.",
    "It's a run-by fruiting!",
    "I do need new glasses.",
    "I can hip-hop, be-bop.",
    "Oh, thank you dear.",
    "Don't fuss with me.",
    "I'll drown you, bastard.",
    "Sorry to frighten dear",
  },
  value = {
    [PickupVariant.PICKUP_HEART] = 5,
    [PickupVariant.PICKUP_BOMB] = 5,
    [PickupVariant.PICKUP_KEY] = 5,
    [PickupVariant.PICKUP_TAROTCARD] = 5,
    [PickupVariant.PICKUP_PILL] = 5,
    [PickupVariant.PICKUP_LIL_BATTERY] = 5,
    [PickupVariant.PICKUP_GRAB_BAG] = 7,
    [PickupVariant.PICKUP_COLLECTIBLE] = 15,

  },
  subvalue = {
    [PickupVariant.PICKUP_HEART] = {
      [HeartSubType.HEART_FULL] = 3,
    }
  },
  costume = Isaac.GetCostumeIdByPath("gfx/characters/old_maid.anm2"),
}

function old_maid.stage(data)
  old_maid.nags_count = 0
  for _, _ in ipairs(old_maid.nags) do
    old_maid.nags_count = old_maid.nags_count + 1
  end

  data.cleaning = {}
end

function old_maid.initalize_player(data, player)
  local tag = support.tag(player)

  data.cleaning[tag] = {
    run = false,
    value = 0,
    frames = 0,
    aniskip = 0
  }
end

function old_maid.reset_player(data, player)
  local tag = support.tag(player)

  if data.cleaning[tag].value > 0 then
    data.cleaning[tag].value = 0
    player:TryRemoveNullCostume(old_maid.costume)
  end
end

function old_maid.use_card(data, card_id, player)
  if card_id ~= old_maid_id then
    return
  end

  local tag = support.tag(player)

  data.cleaning[tag].run = true
end


function old_maid.post_perfect_update(data, player)
  local tag = support.tag(player)

  if not data.cleaning[tag].run then
    return
  end

  data.cleaning[tag].run = false
  data.cleaning[tag].value = 0
  data.cleaning[tag].frames = 140
  data.cleaning[tag].aniskip = 1

  local item_config = Isaac.GetItemConfig()
  local room = Game():GetRoom()

  local entities = room:GetEntities()
  for i = 0, entities.Size - 1 do
    local entity = entities:Get(i)
    if entity.Type == EntityType.ENTITY_SHOPKEEPER then
      local position = entity.Position
      Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, nil)

      entity:Remove()
      room:Update()

      position = room:FindFreeTilePosition(position, 100)

      Isaac.Spawn(EntityType.ENTITY_GREED, 0, 0, position, Vector.Zero, nil)
      Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, nil)

      room:SetClear(false)
      room:Update()
    elseif entity.Type == EntityType.ENTITY_POOP
    or entity.Type == EntityType.ENTITY_FIREPLACE then
      entity:Die()
    elseif entity.Type == EntityType.ENTITY_EFFECT
    or entity.Type == EntityType.ENTITY_TEAR
    or entity.Type == EntityType.ENTITY_PROJECTILE
    or entity.Type == EntityType.ENTITY_BOMB_GRIMACE
    or entity.Type == EntityType.ENTITY_BOMB
    then
      entity:Remove()
    end
  end

  local grid_size = room:GetGridSize()
  for i = 0, grid_size - 1 do
    local entity = room:GetGridEntity(i)
    if entity then
      local type = entity.Desc.Type

      if type == GridEntityType.GRID_POOP
      or type == GridEntityType.GRID_ROCK_ALT
      or type == GridEntityType.GRID_ROCK_ALT2
      then
        room:DestroyGrid(i, true)
      end
    end
  end

  room:Update()
  room:StopRain()

  local entities = room:GetEntities()
  for i = 0, entities.Size - 1 do
    local entity = entities:Get(i)
    if entity.Type == EntityType.ENTITY_EFFECT
    or entity.Type == EntityType.ENTITY_TEAR
    or entity.Type == EntityType.ENTITY_PROJECTILE
    or entity.Type == EntityType.ENTITY_BOMB_GRIMACE
    or entity.Type == EntityType.ENTITY_BOMB
    then
      entity:Remove()
    end
  end

  local value = 0

  for i = 0, entities.Size - 1 do
    local entity = entities:Get(i)
    if entity.Type == EntityType.ENTITY_PICKUP then
      local entity_pickup = entity:ToPickup()
      local entity_value = old_maid.value[entity_pickup.Variant]

      local remove = true
      local config = nil

      if old_maid.subvalue[entity_pickup.Variant] then
        if old_maid.subvalue[entity_pickup.Variant][entity_pickup.SubType] then
          entity_value = old_maid.subvalue[entity_pickup.Variant][entity_pickup.SubType]
        end
      end

      if entity_pickup.Variant == PickupVariant.PICKUP_COIN then
        entity_value = entity_pickup:GetCoinValue()
      elseif entity_pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or entity_pickup.Variant == PickupVariant.PICKUP_TRINKET then
        if entity_pickup.SubType > 0 then
          config = item_config:GetCollectible(entity_pickup.SubType)
          entity_value = config.ShopPrice

          remove = false
          entity_pickup.SubType = 0
          entity_pickup.State = 0
          entity_pickup:Update()
          entity_pickup:Render(Vector.Zero)
        end
      end

      if entity_value then
        value = value + entity_value
      else
        remove = false
      end

      if remove then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
        entity:Remove()
      end
    end
  end

  if value <= 0 then
    return
  end

  player:AddNullCostume(old_maid.costume)

  data.cleaning[tag].value = value

  local damage = data.cleaning[tag].value * old_maid.damage_per_cent

  local entities = room:GetEntities()
  for i = 0, entities.Size - 1 do
    local entity = entities:Get(i)
    if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_GREED then
      entity:TakeDamage(damage, 0, EntityRef(player), 10)
    end
  end
end

function old_maid.render_player(data, player)
  local tag = support.tag(player)

  if data.cleaning[tag].frames <= 0 then
    return
  end

  if data.cleaning[tag].aniskip > 0 and not player:IsExtraAnimationFinished() then
    return
  end

  data.cleaning[tag].aniskip = 0

  data.cleaning[tag].frames = data.cleaning[tag].frames - 1

  local screen = Isaac.WorldToScreen(player.Position)

  local fade = data.cleaning[tag].frames / 100.0
  local shift = (data.cleaning[tag].frames / 50.0) * 5
  if shift > 5 then
    shift = 5
  end

  local message = ""
  local offset_x = 0

  if data.cleaning[tag].value > 100 then
    message = string.format("$%0.2f", data.cleaning[tag].value / 100.00)
    offset_x = -16
  else
    message = string.format("%d\162", data.cleaning[tag].value)
    offset_x = -7
  end

  Isaac.RenderText(message, screen.X + offset_x, screen.Y - 40 - shift, 1, 1, 1, fade)
end

function old_maid.post_new_room(data)
  local maid_found = false

  local hud = Game():GetHUD()

  local player_count = Game():GetNumPlayers()

  for i = 0, player_count - 1 do
    local player = Game():GetPlayer(i)
    for slot = 0, 4 do
      if player:GetCard(slot) == old_maid_id then
        maid_found = true
        break
      end
    end
    if maid_found then
      break
    end
  end

  if maid_found and old_maid.nags_count > 0 then
    local index = (Random() % old_maid.nags_count) + 1
    hud:ShowFortuneText(old_maid.nags[index])
  end
end
