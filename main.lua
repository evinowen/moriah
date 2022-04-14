Moriah = RegisterMod("Moriah", 1512)

local mod = Moriah
local initalized = false

local lunchbox_held = {}
local lunchboxes = {}

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")

function Moriah:initalize()
  Moriah:create_lunchboxs()
  initalized = true
end

function Moriah:create_lunchboxs()
  for i = 0, Game():GetNumPlayers() - 1 do
    lunchboxes[i] = {}
  end

  Moriah:reset_lunchboxs()
end

function Moriah:reset_lunchboxs()
  for i = 0, Game():GetNumPlayers() - 1 do
    lunchbox_held[i] = false
  end
end

function Moriah:use_lunchbox(ItemId, ItemRng, Player, UseFlags, ActiveSlot, CustomVarData)
  if not(initalized) then
    Moriah:initalize()
  end

  if lunchbox_held[0] then
    lunchbox_held[0] = false
    Player:AnimateCollectible(ItemId, "HideItem", "PlayerPickup")
  else
    lunchbox_held[0] = true
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

Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.use_lunchbox, lunchbox_id)
Moriah:AddCallback(ModCallbacks.MC_POST_UPDATE, Moriah.update_lunchbox)
Moriah:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Moriah.reset_lunchboxs)
