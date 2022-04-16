Moriah = RegisterMod("Moriah", 1)

local initalized = false

local lunchboxes = {}
local lunchbox_total = {}

local lunchbox_held = {}
local lunchbox_filled = {}

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")
local packed_lunchbox_id = Isaac.GetItemIdByName("Packed Lunchbox")
local packed_lunchbox_entity_id = Isaac.GetEntityVariantByName("Packed Lunchbox")

function Moriah:print(message)
  Isaac.ConsoleOutput("[Moriah] "..message.."\n")
end

function Moriah:initalize()
  if not initalized then
    Moriah:create_lunchboxes()
    initalized = true
    Moriah:print("Initalize")
  end
end

function Moriah:create_lunchboxes()
  for i = 0, Game():GetNumPlayers() - 1 do
    lunchboxes[i] = {}
    lunchbox_total[i] = 0
  end

  Moriah:reset_lunchboxes()
end

function Moriah:reset_lunchboxes()
  for i = 0, Game():GetNumPlayers() - 1 do
    lunchbox_held[i] = false
    lunchbox_filled[i] = false
  end
end

function Moriah:use_lunchbox(ItemId, ItemRng, Player, UseFlags, ActiveSlot, CustomVarData)
  Moriah:initalize()

  if lunchbox_held[Player.ControllerIndex] then
    lunchbox_held[Player.ControllerIndex] = false

    if lunchbox_filled[Player.ControllerIndex] then
      lunchbox_filled[Player.ControllerIndex] = false
      Player:AddCollectible(packed_lunchbox_id)
      return {
        Discharge = false,
        Remove = false,
        ShowAnim = false,
      }
    end

    Player:AnimateCollectible(ItemId, "HideItem", "PlayerPickup")
  else
    lunchbox_held[Player.ControllerIndex] = true
    Player:AnimateCollectible(ItemId, "LiftItem", "PlayerPickup")
  end

  return {
    Discharge = false,
    Remove = false,
    ShowAnim = false,
  }
end

function Moriah:fill_lunchbox(pickup, collider, low)
  Moriah:initalize()

  local player = collider:ToPlayer()

  if not(player) then
    return
  end

  if lunchbox_held[player.ControllerIndex] then
    player:AnimateCollectible(lunchbox_id, "HideItem", "PlayerPickup")

    pickup:PlayPickupSound()

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)

    lunchbox_filled[player.ControllerIndex] = true
    lunchbox_total[player.ControllerIndex] = lunchbox_total[player.ControllerIndex] + 1

    table.insert(lunchboxes[player.ControllerIndex], {
      Variant = pickup.Variant,
      SubType = pickup.Variant,
      Charge = pickup.Charge
    })

    player:UseActiveItem(lunchbox_id)
    player:RemoveCollectible(lunchbox_id)

    pickup:Remove()

    return true
  end
end

function Moriah:evaluate_cache(player)
  Moriah:initalize()

  Moriah:print("CheckFamiliar "..player.ControllerIndex.." "..lunchbox_total[player.ControllerIndex])
  player:CheckFamiliar(packed_lunchbox_entity_id, lunchbox_total[player.ControllerIndex], RNG())
end

function Moriah:create_packed_lunchbox(familiar)
  familiar.IsFollower = true
end

function Moriah:follow_packed_lunchbox(familiar)
  familiar:FollowParent()
end

Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.use_lunchbox, lunchbox_id)
Moriah:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Moriah.reset_lunchboxes)
Moriah:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Moriah.fill_lunchbox)
Moriah:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Moriah.evaluate_cache, CacheFlag.CACHE_FAMILIARS)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Moriah.create_packed_lunchbox, packed_lunchbox_entity_id)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Moriah.follow_packed_lunchbox, packed_lunchbox_entity_id)
