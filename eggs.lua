local support = require("support")

local egg_tear_id = Isaac.GetEntityVariantByName("Chicken Egg Tear")

local eggs_id = Isaac.GetItemIdByName("Eggs")
local eggs_5_id = Isaac.GetItemIdByName("Eggs (5)")
local eggs_4_id = Isaac.GetItemIdByName("Eggs (4)")
local eggs_3_id = Isaac.GetItemIdByName("Eggs (3)")
local eggs_2_id = Isaac.GetItemIdByName("Eggs (2)")
local eggs_1_id = Isaac.GetItemIdByName("Eggs (1)")
local eggs_0_id = Isaac.GetItemIdByName("Egg Carton")

local eggs = {
  id_table = {
    eggs_id,
    eggs_5_id,
    eggs_4_id,
    eggs_3_id,
    eggs_2_id,
    eggs_1_id,
    eggs_0_id,
  }
}

function eggs.stage(data)
  data.eggs_held = {}
end

function eggs.reset_player(data, player)
  local tag = support.tag(player)

  data.eggs_held[tag] = -1
end

function eggs.use_item(data, item_id, _, player)
  if not support.contains(eggs.id_table, item_id) then
    return
  end

  local tag = support.tag(player)

  if data.eggs_held[tag] < 0 then

    if item_id == eggs_id then
      data.eggs_held[tag] = 6
    elseif item_id == eggs_5_id then
      data.eggs_held[tag] = 5
    elseif item_id == eggs_4_id then
      data.eggs_held[tag] = 4
    elseif item_id == eggs_3_id then
      data.eggs_held[tag] = 3
    elseif item_id == eggs_2_id then
      data.eggs_held[tag] = 2
    elseif item_id == eggs_1_id then
      data.eggs_held[tag] = 1
    elseif item_id == eggs_0_id then
      support.print("Egg Carton!")
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
    data.eggs_held[tag] = -1

    player:AnimateCollectible(item_id, "HideItem", "PlayerPickup")
  end

  return {
    Discharge = false,
    Remove = false,
    ShowAnim = false,
  }
end

function eggs.render_player(data, player)
  local tag = support.tag(player)
  local held_eggs = data.eggs_held[tag]

  if held_eggs < 0 then
    return
  end

  if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
  or Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
  or Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
  or Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
    support.print("Throw Egg")
    data.eggs_held[tag] = -1

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

support.print("Loaded moriah.eggs")
return eggs
