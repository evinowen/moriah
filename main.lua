Moriah = RegisterMod("Moriah", 1)

local json = require("json")
local support = require("support")

local items = {
  bowtie      = require("bowtie"),
  coffee_bean = require("coffee_bean"),
  eggs        = require("eggs"),
  fishbowl    = require("fishbowl"),
  helium      = require("helium"),
  lunchbox    = require("lunchbox"),
  plant       = require("plant"),
  tissues     = require("tissues"),
  whistle     = require("whistle"),
}

function Moriah:Validate()
  if not (Moriah.Data and Moriah.Data.initalized) then
    Moriah:start(true)
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

function Moriah:record()
  Moriah:SaveData(json.encode(Moriah.Data))
end

function Moriah:remix_arguments(arguments)
  table.remove(arguments, 1)
  table.insert(arguments, 1, Moriah.Data)
  return arguments
end

function Moriah:start(continue)
  support.print("Start")
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

Moriah:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Moriah.start)

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

Moriah:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Moriah.reset)

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

Moriah:AddCallback(ModCallbacks.MC_POST_RENDER, Moriah.render)

local methods = {
  {
    flag = ModCallbacks.MC_USE_ITEM,
    name = "use_item",
  },
  {
    flag = ModCallbacks.MC_EVALUATE_CACHE,
    name = "evaluate_cache",
  },
  {
    flag = ModCallbacks.MC_POST_FIRE_TEAR,
    name = "fire",
  },
  {
    flag = ModCallbacks.MC_FAMILIAR_INIT,
    name = "familiar_init",
  },
  {
    flag = ModCallbacks.MC_FAMILIAR_UPDATE,
    name = "familiar_update",
  },
  {
    flag = ModCallbacks.MC_ENTITY_TAKE_DMG,
    name = "entity_take_damage",
  },
  {
    flag = ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
    name = "pre_familiar_collision",
  },
  {
    flag = ModCallbacks.MC_PRE_PICKUP_COLLISION,
    name = "pre_pickup_collision",
  },
  {
    flag = ModCallbacks.MC_PRE_PROJECTILE_COLLISION,
    name = "pre_projectile_collision",
  },
  {
    flag = ModCallbacks.MC_PRE_PLAYER_COLLISION,
    name = "pre_player_collision",
  },
  {
    flag = ModCallbacks.MC_PRE_TEAR_COLLISION,
    name = "pre_tear_collision",
  },
}

function Moriah:callback_template(name)
  return function(...)
    local arguments = Moriah:remix_arguments({...})

    Moriah:Validate()

    local result = nil
    for _, item in pairs(items) do
      if item[name] then
        local local_result = item[name](table.unpack(arguments))

        if local_result ~= nil then
          result = local_result
        end
      end
    end

    Moriah:record()
    return result
  end
end

for _, method in ipairs(methods) do
  support.print("AddCallback "..method.name)
  Moriah:AddCallback(method.flag, Moriah:callback_template(method.name))
end

support.print("Loaded moriah")
