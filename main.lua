Moriah = RegisterMod("Moriah", 1512)

local mod = Moriah
local initalized = false

local lunchboxes = {}

local lunchbox_held = {}
local lunchbox_filled = {}

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")

function Moriah:initalize()
  Moriah:create_lunchboxes()
  initalized = true
end

function Moriah:create_lunchboxes()
  for i = 0, Game():GetNumPlayers() - 1 do
    lunchboxes[i] = {}
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
  if not initalized then
    Moriah:initalize()
  end

  if lunchbox_held[Player.ControllerIndex] then
    lunchbox_held[Player.ControllerIndex] = false

    if lunchbox_filled[Player.ControllerIndex] then
      lunchbox_filled[Player.ControllerIndex] = false
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

function Moriah:update_lunchbox()
  for i = 0, Game():GetNumPlayers() - 1 do
    local player = Isaac.GetPlayer(i)

    if player:HasCollectible(lunchbox_id) then
      if lunchbox_held[i] then
        player:CanShoot(false)
      end
    end
  end
end


function Moriah:fill_lunchbox(pickup, collider, low)
  local player = collider:ToPlayer()

  if not(player) then
    return
  end

  if lunchbox_held[player.ControllerIndex] then
    player:AnimateCollectible(lunchbox_id, "HideItem", "PlayerPickup")

    pickup:PlayPickupSound()

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
    lunchbox_filled[player.ControllerIndex] = true

    player:UseActiveItem(lunchbox_id)
    player:RemoveCollectible(lunchbox_id)

    pickup:Remove()

    return true
  end
end

Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.use_lunchbox, lunchbox_id)
Moriah:AddCallback(ModCallbacks.MC_POST_UPDATE, Moriah.update_lunchbox)
Moriah:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Moriah.reset_lunchboxes)
Moriah:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Moriah.fill_lunchbox)
