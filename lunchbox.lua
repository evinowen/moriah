local support = require "support"

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")
local packed_lunchbox_id = Isaac.GetItemIdByName("Packed Lunchbox")
local packed_lunchbox_entity_id = Isaac.GetEntityVariantByName("Packed Lunchbox")

local lunchbox = {}

function lunchbox.stage(data)
  support.print("lunchbox stage")
  data.lunchboxes = {}
  data.lunchbox_total = {}
  data.lunchbox_held = {}
  data.lunchbox_filled = {}
  data.lunchbox_opened = {}
  data.lunchbox_release = {}
end

function lunchbox.initalize_player(data, player)
  local tag = support.tag(player)

  support.print("lunchbox "..tag.." init")
  data.lunchboxes[tag] = {}
  data.lunchbox_total[tag] = 0
  data.lunchbox_release[tag] = 0
end

function lunchbox.reset_player(data, player)
  local tag = support.tag(player)

  support.print("lunchbox "..tag.." reset")
  data.lunchbox_held[tag] = false
  data.lunchbox_filled[tag] = false
  data.lunchbox_opened[tag] = false
end

function lunchbox.use_item(data, item_id, _, player)
  if item_id ~= lunchbox_id then
    return
  end

  local tag = support.tag(player)

  if data.lunchbox_held[tag] then
    data.lunchbox_held[tag] = false

    if data.lunchbox_filled[tag] then
      data.lunchbox_filled[tag] = false

      player:AddCollectible(packed_lunchbox_id)

      return {
        Discharge = false,
        Remove = false,
        ShowAnim = false,
      }
    end

    player:AnimateCollectible(item_id, "HideItem", "PlayerPickup")
  else
    data.lunchbox_held[tag] = true
    player:AnimateCollectible(item_id, "LiftItem", "PlayerPickup")
  end

  return {
    Discharge = false,
    Remove = false,
    ShowAnim = false,
  }
end

function lunchbox.pre_pickup_collision(data, pickup, collider)
  local player = collider:ToPlayer()

  if not(player) then
    return
  end

  local tag = support.tag(player)

  if data.lunchbox_held[tag] then
    player:AnimateCollectible(lunchbox_id, "HideItem", "PlayerPickup")

    pickup:PlayPickupSound()

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)

    data.lunchbox_filled[tag] = true
    data.lunchbox_total[tag] = data.lunchbox_total[tag] + 1

    table.insert(data.lunchboxes[tag], {
      Variant = pickup.Variant,
      SubType = pickup.SubType,
      Charge = pickup.Charge
    })

    player:UseActiveItem(lunchbox_id)
    player:RemoveCollectible(lunchbox_id)

    pickup:Remove()

    return true
  end
end

function lunchbox.render_player(data, player)
  local tag = support.tag(player)

  if data.lunchbox_total[tag] > 0 then
    if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
      data.lunchbox_release[tag] = data.lunchbox_release[tag] + 1

      if data.lunchbox_release[tag] >= 100 then
        data.lunchbox_release[tag] = 0
        data.lunchbox_opened[tag] = true
      end
    else
      data.lunchbox_release[tag] = 0
    end
  end
end

function lunchbox.evaluate_cache(data, player, flag)
  if flag == CacheFlag.CACHE_FAMILIARS then
    support.print("CACHE_FAMILIARS")

    local tag = support.tag(player)

    player:CheckFamiliar(packed_lunchbox_entity_id, data.lunchbox_total[tag], RNG())
  end
end

function lunchbox.familiar_init(data, familiar)
  if familiar.Variant ~= packed_lunchbox_entity_id then
    return
  end

  familiar.IsFollower = true
end

function lunchbox.familiar_update(data, familiar)
  if familiar.Variant ~= packed_lunchbox_entity_id then
    return
  end

  familiar:FollowParent()

  local player = familiar.Player
  local tag = support.tag(player)

  if data.lunchbox_opened[tag] then
    data.lunchbox_opened[tag] = false

    local lunchbox = data.lunchboxes[tag][1]

    table.remove(data.lunchboxes[tag], 1)
    data.lunchbox_total[tag] = data.lunchbox_total[tag] - 1

    local position = familiar.Position

    player:RemoveCollectible(packed_lunchbox_id)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    player:EvaluateItems()

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, nil)
    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, lunchbox.Variant, lunchbox.SubType, position, Vector.Zero, nil)
    -- pickup.Charge = lunchbox.Charge
  end
end

support.print("Loaded moriah.lunchbox")
return lunchbox
