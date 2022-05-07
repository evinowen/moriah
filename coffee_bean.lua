local support = require("support")

local coffee_bean_id = Isaac.GetItemIdByName("Coffee Bean")

local coffee_bean = {
  id_table = { coffee_bean_id }
}

function coffee_bean.evaluate_cache(data, player, flag)
  if flag == CacheFlag.CACHE_SPEED then
    if player:HasCollectible(coffee_bean_id) then
      player.MoveSpeed = player.MoveSpeed + 0.25
    end
  end
end

function coffee_bean.entity_take_damage(data, damaged)
  local player = damaged:ToPlayer()

  if not player then
    return
  end

  local tag = support.tag(player)
  if player:HasCollectible(coffee_bean_id) then
    local room = Game():GetRoom()
    local index = room:GetGridIndex(player.Position)
    local type = support.PoopSubType.REGULAR

    if Random() % 10 <= 5 then
      local type = support.PoopSubType.CORNY
    end

    room:SpawnGridEntity(index, GridEntityType.GRID_POOP, type, support.random_seed(), 0)
  end
end

return coffee_bean
