Moriah = RegisterMod("Moriah", 1)

local json = require("json")
local support = require "support"

local items = {
  fishbowl  = require "fishbowl",
  lunchbox  = require "lunchbox",
  eggs      = require "eggs",
  whistle   = require "whistle",
}

function Moriah:Validate()
  if not (Moriah.Data and Moriah.Data.initalized) then
    Moriah:start(true)
  end
end

function Moriah:start(continue)
  support.print("start")
  Moriah:stage()

  if continue and Moriah:HasData() then
    support.print("Continue Game")

    local encoded = Moriah:LoadData()
    support.print("Load Results: "..encoded)
    support.merge(Moriah.Data, json.decode(encoded))
  else
    support.print("New Game")

    Moriah:initalize()

    support.print("Initalized: "..json.encode(Moriah.Data))

    Moriah:record()
  end

  local player_count = Game():GetNumPlayers()

  for i = 0, player_count - 1 do
    local player = Game():GetPlayer(i)
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
  end
end

function Moriah:stage()
  support.print("stage")
  Moriah.Data = {}

  for _, item in pairs(items) do
    if item.stage ~= nil then
      item.stage(Moriah.Data)
    end
  end
end

function Moriah:initalize()
  local player_count = Game():GetNumPlayers()
  local players = {}
  for i = 0, player_count - 1 do
    table.insert(players, Game():GetPlayer(i))
  end

  for _, item in pairs(items) do
    if item.initalize_player ~= nil then
      for _, player in pairs(players) do
        item.initalize_player(Moriah.Data, player)
      end
    end
  end

  Moriah:reset()

  Moriah.Data.initalized = true
end

function Moriah:reset()
  local player_count = Game():GetNumPlayers()
  local players = {}
  for i = 0, player_count - 1 do
    table.insert(players, Game():GetPlayer(i))
  end

  for _, item in pairs(items) do
    if item.reset_player ~= nil then
      for _, player in pairs(players) do
        item.reset_player(Moriah.Data, player)
      end
    end
  end
end

function Moriah:record()
  Moriah:SaveData(json.encode(Moriah.Data))
end

function Moriah:use_item(item_id, _, player, _, _, _)
  Moriah:Validate()

  for _, item in pairs(items) do
    if support.contains(item.id_table, item_id) then
      if item.use_item ~= nil then
        support.print("Use Item "..item_id)
        local tag = support.tag(player)
        support.print("Use Tag "..tag)
        return item.use_item(Moriah.Data, item_id, player)
      end
      return
    end
  end

  Moriah:record()
end

function Moriah:pre_pickup_collision(pickup, collider)
  Moriah:Validate()

  local result = nil

  for _, item in pairs(items) do
    if item.pre_pickup_collision then
      local local_result = item.pre_pickup_collision(Moriah.Data, pickup, collider)

      if local_result ~= nil then
        result = local_result
      end
    end
  end

  Moriah:record()
  return result
end

function Moriah:evaluate_cache(player, flag)
  Moriah:Validate()

  support.print("evaluate_cache "..flag)
  for _, item in pairs(items) do
    if item.evaluate_cache then
      item.evaluate_cache(Moriah.Data, player, flag)
    end
  end

  Moriah:record()
end

function Moriah:familiar_init(player, flag)
  Moriah:Validate()

  for _, item in pairs(items) do
    if item.familiar_init then
      item.familiar_init(Moriah.Data, player, flag)
    end
  end

  Moriah:record()
end

function Moriah:familiar_update(player, flag)
  Moriah:Validate()

  for _, item in pairs(items) do
    if item.familiar_update then
      item.familiar_update(Moriah.Data, player, flag)
    end
  end

  Moriah:record()
end

function Moriah:render()
  Moriah:Validate()

  local player_count = Game():GetNumPlayers()
  local players = {}
  for i = 0, player_count - 1 do
    table.insert(players, Game():GetPlayer(i))
  end

  for _, item in pairs(items) do
    if item.render then
      item.render(Moriah.Data)
    end

    if item.render_player then
      for _, player in pairs(players) do
        item.render_player(Moriah.Data, player)
      end
    end
  end

  Moriah:record()
end

function Moriah:fire(tear)
  Moriah:Validate()

  for _, item in pairs(items) do
    if item.fire then
      item.fire(Moriah.Data, tear)
    end
  end

  Moriah:record()
end

function Moriah:pre_projectile_collision(projectile, collider)
  Moriah:Validate()

  local result = nil

  for _, item in pairs(items) do
    if item.pre_projectile_collision then
      local local_result = item.pre_projectile_collision(Moriah.Data, projectile, collider)

      if local_result ~= nil then
        result = local_result
      end
    end
  end

  Moriah:record()
  return result
end

Moriah:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Moriah.evaluate_cache)
Moriah:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Moriah.fire)
Moriah:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Moriah.start)
Moriah:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Moriah.reset)
Moriah:AddCallback(ModCallbacks.MC_POST_RENDER, Moriah.render)
Moriah:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Moriah.pre_pickup_collision)
Moriah:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, Moriah.pre_projectile_collision)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Moriah.familiar_init)
Moriah:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Moriah.familiar_update)
Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.use_item)

support.print("Loaded moriah")
