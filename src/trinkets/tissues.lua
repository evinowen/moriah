local tissues_id = Isaac.GetTrinketIdByName("Tissues")

local tissues = {
  id_table = { tissues_id },
  tick = 0,
  tick_length = 5,
  tissue_throw_speed = 0.2,
  tissue_reach_squared = 2048,
  creep = {
    EffectVariant.CREEP_RED,
    EffectVariant.CREEP_GREEN,
    EffectVariant.CREEP_YELLOW,
    EffectVariant.CREEP_WHITE,
    EffectVariant.CREEP_BLACK,
    EffectVariant.PLAYER_CREEP_LEMON_MISHAP,
    EffectVariant.PLAYER_CREEP_HOLYWATER,
    EffectVariant.PLAYER_CREEP_WHITE,
    EffectVariant.PLAYER_CREEP_BLACK,
    EffectVariant.PLAYER_CREEP_RED,
    EffectVariant.PLAYER_CREEP_GREEN,
    EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL,
    EffectVariant.CREEP_BROWN,
    EffectVariant.PLAYER_CREEP_LEMON_PARTY,
    EffectVariant.PLAYER_CREEP_PUDDLE_MILK,
    EffectVariant.CREEP_SLIPPERY_BROWN,
    EffectVariant.CREEP_SLIPPERY_BROWN_GROWING,
    EffectVariant.CREEP_STATIC,
    EffectVariant.CREEP_LIQUID_POOP,
  },
  effects = {
    queue = {},
    objects = {},
  },
}

function tissues.stage(data)
  data.tissues = {}
end

function tissues.initalize_player(data, player)
  local tag = support.tag(player)

  data.tissues[tag] = {
    tick = tissues.tick_length,
    current = 0
  }
end

function tissues.post_new_room(data)
  tissues.effects.queue = nil
  tissues.effects.objects = {}
end


function tissues.fire(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if not player then
    return
  end

  if player:HasTrinket(tissues_id, true) then
    tear:Remove()

    local tag = support.tag(player)
    data.tissues[tag].current = data.tissues[tag].current + 1

    if data.tissues[tag].current >= 10 then
      local velocity = player.Velocity:Normalized() * -1 * tissues.tissue_throw_speed
      local tissue = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WOOD_PARTICLE, 1, player.Position, velocity, player)
      tissue:SetColor(Color(0.8, 0.8, 0.9, 1, 0.9, 0.9, 0.9), -1, 1, false, false)

      data.tissues[tag].current = 0
    end
  end
end

function tissues.pre_entity_spawn(data, type, variant, subtype, position, velocity, spawner, seed)
  if type ~= EntityType.ENTITY_EFFECT then
    return
  end

  if not support.contains(tissues.creep, variant) then
    return
  end

  if tissues.effects.queue == nil then
    tissues.effects.queue = {}
  end

  table.insert(tissues.effects.queue, seed)
end

function tissues.post_update(data)
  if tissues.effects.queue == nil then
    return
  end

  local room = Game():GetRoom()

  local entities = room:GetEntities()
  local entities_size = entities.Size - 1
  for i = 0, entities_size do
    local entity = entities:Get(i)

    if support.contains(tissues.effects.queue, entity.InitSeed) then
      table.insert(tissues.effects.objects, entity:ToEffect())
    end
  end

  tissues.effects.queue = nil

  tissues.tick = tissues.tick - 1

  if tissues.tick > 0 then
    return
  end

  tissues.tick = tissues.tick_length

  local players = {}
  local player_count = Game():GetNumPlayers()

  for i = 0, player_count do
    local player = Game():GetPlayer(i)

    if player:HasTrinket(tissues_id, true) then
      table.insert(players, player)
    end
  end

  for _, player in ipairs(players) do
    local objects = {}

    for _, effect in ipairs(tissues.effects.objects) do
      if (player.Position - effect.Position):LengthSquared() <= tissues.tissue_reach_squared then
        effect:Kill()
      else
        table.insert(objects, effect)
      end
    end

    tissues.effects.objects = objects
  end
end
