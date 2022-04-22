local json = require("json")

Moriah = RegisterMod("Moriah", 1)

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")
local packed_lunchbox_id = Isaac.GetItemIdByName("Packed Lunchbox")
local packed_lunchbox_entity_id = Isaac.GetEntityVariantByName("Packed Lunchbox")

function Moriah:print(message)
  Isaac.ConsoleOutput("[Moriah] "..message.."\n")
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
    lunchbox_release = {}
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

    Moriah:print("test1 "..Moriah:tag(player.ControllerIndex))
    Moriah:print("test2 "..json.encode(Moriah.Data.lunchbox_total))
    Moriah:print("test3 "..Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)])
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

  Moriah:print("CheckFamiliar "..Moriah:tag(player.ControllerIndex).." "..Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)])
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

    Moriah:print("lunchboxes? "..json.encode(Moriah.Data.lunchboxes[Moriah:tag(player.ControllerIndex)]))
    local lunchbox = Moriah.Data.lunchboxes[Moriah:tag(player.ControllerIndex)][1]
    Moriah:print("lunchbox! "..json.encode(lunchbox))

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

function Moriah:render()
  if not (Moriah.Data and Moriah.Data.initalized) then
    Moriah:start(true)
    return
  end

  local players = Game():GetNumPlayers()
  for i = 0, players - 1 do
    local player = Game():GetPlayer(i)

    Moriah:render_lunchbox(player)
  end
end

Moriah:AddCallback(ModCallbacks.MC_POST_RENDER, Moriah.render)
