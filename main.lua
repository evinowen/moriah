local json = require("json")

Moriah = RegisterMod("Moriah", 1)

Moriah.Data = {
  initalized = false,
  lunchboxes = {},
  lunchbox_total = {},
  lunchbox_held = {},
  lunchbox_filled = {},
}

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")
local packed_lunchbox_id = Isaac.GetItemIdByName("Packed Lunchbox")
local packed_lunchbox_entity_id = Isaac.GetEntityVariantByName("Packed Lunchbox")

function Moriah:print(message)
  Isaac.ConsoleOutput("[Moriah] "..message.."\n")
end

function Moriah:tag(number)
  return "player"..number
end

function Moriah:initalize(continue)
	if continue and Moriah:HasData() then
    Moriah:print("Load")
    local encoded = Moriah:LoadData()
    Moriah:print("Data: "..encoded)
		Moriah.Data = json.decode(encoded)
  end

  if not Moriah.Data.initalized then
    Moriah:print("Initalize")
    Moriah:create_lunchboxes()
    Moriah.Data.initalized = true
  end
end

function Moriah:record()
  Moriah:SaveData(json.encode(Moriah.Data))
end

function Moriah:create_lunchboxes()
  local players = Game():GetNumPlayers()
  for i = 0, players - 1 do
    local player = Game():GetPlayer(i)
    Moriah.Data.lunchboxes[Moriah:tag(player.ControllerIndex)] = {}
    Moriah.Data.lunchbox_total[Moriah:tag(player.ControllerIndex)] = 0
  end

  Moriah:reset_lunchboxes()
end

function Moriah:reset_lunchboxes()
  local players = Game():GetNumPlayers()
  for i = 0, players - 1 do
    local player = Game():GetPlayer(i)
    Moriah.Data.lunchbox_held[Moriah:tag(player.ControllerIndex)] = false
    Moriah.Data.lunchbox_filled[Moriah:tag(player.ControllerIndex)] = false
  end
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
      SubType = pickup.Variant,
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
end

Moriah:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Moriah.initalize)
Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.use_lunchbox, lunchbox_id)
Moriah:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Moriah.reset_lunchboxes)
Moriah:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Moriah.fill_lunchbox)
Moriah:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Moriah.evaluate_cache, CacheFlag.CACHE_FAMILIARS)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Moriah.create_packed_lunchbox, packed_lunchbox_entity_id)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Moriah.follow_packed_lunchbox, packed_lunchbox_entity_id)
