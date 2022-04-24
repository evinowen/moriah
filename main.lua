local json = require("json")

Moriah = RegisterMod("Moriah", 1)

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")
local packed_lunchbox_id = Isaac.GetItemIdByName("Packed Lunchbox")
local packed_lunchbox_entity_id = Isaac.GetEntityVariantByName("Packed Lunchbox")

function Moriah:print(message)
  Isaac.ConsoleOutput("[Moriah] "..message.."\n")
end

function Moriah:contains(table, search)
  for index, value in ipairs(table) do
      if value == search then
          return true
      end
  end

  return false
end

function Moriah:merge(base, addition)
  for key, value in pairs(addition) do
    base[key] = value
  end
end

function Moriah:tag(number)
  return "p."..number
end

function Moriah:start(continue)
  Moriah:stage()

  if continue and Moriah:HasData() then
    Moriah:print("Continue Game")

    local encoded = Moriah:LoadData()
    Moriah:print("Load Results: "..encoded)
    Moriah:merge(Moriah.Data, json.decode(encoded))
  else
    Moriah:print("New Game")

    Moriah:initalize()

    Moriah:print("Initalized: "..json.encode(Moriah.Data))

    Moriah:record()
  end

  local players = Game():GetNumPlayers()

  for i = 0, players - 1 do
    local player = Game():GetPlayer(i)
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
  end
end

function Moriah:stage()
  Moriah.Data = {
    initalized = false,
    lunchboxes = {},
    lunchbox_total = {},
    lunchbox_held = {},
    lunchbox_filled = {},
    lunchbox_opened = {},
    lunchbox_release = {},
    eggs_held = {}
  }
end

function Moriah:initalize()
  local players = Game():GetNumPlayers()
  for i = 0, players - 1 do
    local player = Game():GetPlayer(i)
    Moriah.Data.lunchboxes[Moriah:tag(player.ControllerIndex)] = {}
    Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)] = 0
    Moriah.Data.lunchbox_release[Moriah:tag(player.ControllerIndex)] = 0
  end

  Moriah:reset()

  Moriah.Data.initalized = true
end

function Moriah:reset()
  local players = Game():GetNumPlayers()
  for i = 0, players - 1 do
    local player = Game():GetPlayer(i)
    Moriah.Data.lunchbox_held[Moriah:tag(player.ControllerIndex)] = false
    Moriah.Data.lunchbox_filled[Moriah:tag(player.ControllerIndex)] = false
    Moriah.Data.lunchbox_opened[Moriah:tag(player.ControllerIndex)] = false
    Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = -1
  end
end

function Moriah:record()
  Moriah:SaveData(json.encode(Moriah.Data))
end

function Moriah:use_lunchbox(item_id, _, player, _, _, _)
  if Moriah.Data.lunchbox_held[Moriah:tag(player.ControllerIndex)] then
    Moriah.Data.lunchbox_held[Moriah:tag(player.ControllerIndex)] = false

    if Moriah.Data.lunchbox_filled[Moriah:tag(player.ControllerIndex)] then
      Moriah.Data.lunchbox_filled[Moriah:tag(player.ControllerIndex)] = false

      player:AddCollectible(packed_lunchbox_id)

      Moriah:record()

      return {
        Discharge = false,
        Remove = false,
        ShowAnim = false,
      }
    end

    player:AnimateCollectible(item_id, "HideItem", "PlayerPickup")
  else
    Moriah.Data.lunchbox_held[Moriah:tag(player.ControllerIndex)] = true
    player:AnimateCollectible(item_id, "LiftItem", "PlayerPickup")
  end

  Moriah:record()
  return {
    Discharge = false,
    Remove = false,
    ShowAnim = false,
  }
end

function Moriah:fill_lunchbox(pickup, collider, _)
  local player = collider:ToPlayer()

  if not(player) then
    return
  end

  if Moriah.Data.lunchbox_held[Moriah:tag(player.ControllerIndex)] then
    player:AnimateCollectible(lunchbox_id, "HideItem", "PlayerPickup")

    pickup:PlayPickupSound()

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)

    Moriah.Data.lunchbox_filled[Moriah:tag(player.ControllerIndex)] = true
    Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)] = Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)] + 1

    table.insert(Moriah.Data.lunchboxes[Moriah:tag(player.ControllerIndex)], {
      Variant = pickup.Variant,
      SubType = pickup.SubType,
      Charge = pickup.Charge
    })

    player:UseActiveItem(lunchbox_id)
    player:RemoveCollectible(lunchbox_id)

    pickup:Remove()

    Moriah:record()
    return true
  end
end

function Moriah:evaluate_cache(player)
  if not Moriah.Data.initalized then
    return
  end

  player:CheckFamiliar(packed_lunchbox_entity_id, Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)], RNG())
end

function Moriah:create_packed_lunchbox(familiar)
  familiar.IsFollower = true
end

function Moriah:follow_packed_lunchbox(familiar)
  familiar:FollowParent()

  local player = familiar.Player

  if Moriah.Data.lunchbox_opened[Moriah:tag(player.ControllerIndex)] then
    Moriah.Data.lunchbox_opened[Moriah:tag(player.ControllerIndex)] = false

    local lunchbox = Moriah.Data.lunchboxes[Moriah:tag(player.ControllerIndex)][1]

    table.remove(Moriah.Data.lunchboxes[Moriah:tag(player.ControllerIndex)], 1)
    Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)] = Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)] - 1

    local position = familiar.Position

    player:RemoveCollectible(packed_lunchbox_id)
    player:EvaluateItems()

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, nil)
    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, lunchbox.Variant, lunchbox.SubType, position, Vector.Zero, nil)
    -- pickup.Charge = lunchbox.Charge

    Moriah:record()
  end
end

function Moriah:render_lunchbox(player)
  if Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)] > 0 then
    if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
      Moriah.Data.lunchbox_release[Moriah:tag(player.ControllerIndex)] = Moriah.Data.lunchbox_release[Moriah:tag(player.ControllerIndex)] + 1

      if Moriah.Data.lunchbox_release[Moriah:tag(player.ControllerIndex)] >= 100 then
        Moriah.Data.lunchbox_release[Moriah:tag(player.ControllerIndex)] = 0
        Moriah.Data.lunchbox_opened[Moriah:tag(player.ControllerIndex)] = true
      end
    else
      Moriah.Data.lunchbox_release[Moriah:tag(player.ControllerIndex)] = 0
    end
  end
end

Moriah:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Moriah.start)
Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.use_lunchbox, lunchbox_id)
Moriah:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Moriah.reset)
Moriah:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Moriah.fill_lunchbox)
Moriah:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Moriah.evaluate_cache, CacheFlag.CACHE_FAMILIARS)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Moriah.create_packed_lunchbox, packed_lunchbox_entity_id)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Moriah.follow_packed_lunchbox, packed_lunchbox_entity_id)

local egg_tear_id = Isaac.GetEntityVariantByName("Chicken Egg Tear")

local eggs_id = Isaac.GetItemIdByName("Eggs")
local eggs_5_id = Isaac.GetItemIdByName("Eggs (5)")
local eggs_4_id = Isaac.GetItemIdByName("Eggs (4)")
local eggs_3_id = Isaac.GetItemIdByName("Eggs (3)")
local eggs_2_id = Isaac.GetItemIdByName("Eggs (2)")
local eggs_1_id = Isaac.GetItemIdByName("Eggs (1)")
local eggs_0_id = Isaac.GetItemIdByName("Egg Carton")

local egg_id_table = {
  eggs_id,
  eggs_5_id,
  eggs_4_id,
  eggs_3_id,
  eggs_2_id,
  eggs_1_id,
  eggs_0_id,
}

function Moriah:hold_eggs(item_id, _, player, _, _, _)
  if not Moriah:contains(egg_id_table, item_id) then
    return
  end

  if Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] < 0 then

    if item_id == eggs_id then
      Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = 6
    elseif item_id == eggs_5_id then
      Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = 5
    elseif item_id == eggs_4_id then
      Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = 4
    elseif item_id == eggs_3_id then
      Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = 3
    elseif item_id == eggs_2_id then
      Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = 2
    elseif item_id == eggs_1_id then
      Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = 1
    elseif item_id == eggs_0_id then
      Isaac.ConsoleOutput("[Moriah] Egg Carton!\n")
      player:RemoveCollectible(eggs_0_id)
      player:AddHearts(2)
      return {
        Discharge = true,
        Remove = true,
        ShowAnim = true,
      }
    end

    player:AnimateCollectible(item_id, "LiftItem", "PlayerPickup")
  else
    Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = -1

    player:AnimateCollectible(item_id, "HideItem", "PlayerPickup")
  end

  return {
    Discharge = false,
    Remove = false,
    ShowAnim = false,
  }
end

function Moriah:render_eggs(player)
  local held_eggs = Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)]

  if held_eggs < 0 then
    return
  end

  if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
  or Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
  or Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
  or Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
    Moriah:print("Throw Egg")
    Moriah.Data.eggs_held[Moriah:tag(player.ControllerIndex)] = -1

    local fire_egg = false

    if held_eggs == 6 then
      player:AnimateCollectible(eggs_id, "HideItem", "PlayerPickup")
      player:RemoveCollectible(eggs_id)
      player:AddCollectible(eggs_5_id)
      fire_egg = true
    elseif held_eggs == 5 then
      player:AnimateCollectible(eggs_5_id, "HideItem", "PlayerPickup")
      player:RemoveCollectible(eggs_5_id)
      player:AddCollectible(eggs_4_id)
      fire_egg = true
    elseif held_eggs == 4 then
      player:AnimateCollectible(eggs_4_id, "HideItem", "PlayerPickup")
      player:RemoveCollectible(eggs_4_id)
      player:AddCollectible(eggs_3_id)
      fire_egg = true
    elseif held_eggs == 3 then
      player:AnimateCollectible(eggs_3_id, "HideItem", "PlayerPickup")
      player:RemoveCollectible(eggs_3_id)
      player:AddCollectible(eggs_2_id)
      fire_egg = true
    elseif held_eggs == 2 then
      player:AnimateCollectible(eggs_2_id, "HideItem", "PlayerPickup")
      player:RemoveCollectible(eggs_2_id)
      player:AddCollectible(eggs_1_id)
      fire_egg = true
    elseif held_eggs == 1 then
      player:AnimateCollectible(eggs_1_id, "HideItem", "PlayerPickup")
      player:RemoveCollectible(eggs_1_id)
      player:AddCollectible(eggs_0_id)
      fire_egg = true
    end

    player:DischargeActiveItem()

    if fire_egg then
      local entity = Isaac.Spawn(EntityType.ENTITY_TEAR, egg_tear_id, 0, player.Position, player:GetAimDirection() * 7, player)
      local tear = entity:ToTear()
      tear:AddTearFlags(TearFlags.TEAR_KNOCKBACK)
      tear:AddTearFlags(TearFlags.TEAR_BAIT)

      tear.FallingSpeed = -8
      tear.FallingAcceleration = 0.05

      local sprite = tear:GetSprite()
      sprite:Play(sprite:GetDefaultAnimation(), true)
      sprite.Scale = Vector(0.55, 0.55)
    end
  end
end

Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.hold_eggs)

function Moriah:render()
  if not (Moriah.Data and Moriah.Data.initalized) then
    Moriah:start(true)
    return
  end

  local players = Game():GetNumPlayers()
  for i = 0, players - 1 do
    local player = Game():GetPlayer(i)

    Moriah:render_lunchbox(player)
    Moriah:render_eggs(player)
  end
end

Moriah:AddCallback(ModCallbacks.MC_POST_RENDER, Moriah.render)
