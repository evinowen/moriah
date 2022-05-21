Moriah = RegisterMod("Moriah", 1)

local json = require("json")

local actors = {
  bowtie,
  butchers_apron,
  coffee_bean,
  eggs,
  fishbowl,
  helium,
  hymnal,
  lunchbox,
  old_maid,
  plant,
  tissues,
  whistle,
}

function Moriah:Validate()
  if not (Moriah.Data and Moriah.Data.initalized) then
    Moriah:start(true)
  end
end

function Moriah:stage()
  support.print("stage")
  Moriah.Data = {}

  for _, actor in pairs(actors) do
    if actor.stage ~= nil then
      actor.stage(Moriah.Data)
    end
  end
end

function Moriah:initalize()
  local player_count = Game():GetNumPlayers()
  local players = {}
  for i = 0, player_count - 1 do
    table.insert(players, Game():GetPlayer(i))
  end

  for _, actor in pairs(actors) do
    if actor.initalize_player ~= nil then
      for _, player in pairs(players) do
        actor.initalize_player(Moriah.Data, player)
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

  for _, actor in pairs(actors) do
    if actor.reset_player ~= nil then
      for _, player in pairs(players) do
        actor.reset_player(Moriah.Data, player)
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

  for _, actor in pairs(actors) do
    if actor.render then
      actor.render(Moriah.Data)
    end

    if actor.render_player then
      for _, player in pairs(players) do
        actor.render_player(Moriah.Data, player)
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
    flag = ModCallbacks.MC_USE_CARD,
    name = "use_card",
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
    flag = ModCallbacks.MC_POST_NEW_ROOM,
    name = "post_new_room",
  },
  {
    flag = ModCallbacks.MC_POST_PEFFECT_UPDATE,
    name = "post_perfect_update",
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
    for _, actor in pairs(actors) do
      if actor[name] then
        local local_result = actor[name](table.unpack(arguments))

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
