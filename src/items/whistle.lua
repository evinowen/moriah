local whistle_id = Isaac.GetItemIdByName("Whistle")
local whistle_projectile_id = Isaac.GetEntityVariantByName("Whistle Projectile")
local whistle_sound_id = Isaac.GetSoundIdByName("Whistle")
local whistle_secret_sound_id = Isaac.GetSoundIdByName("Whistle Secret")

local whistle = {
  id_table = { whistle_id },
  tune_delay = 100,
}

function whistle.stage(data)
  data.whistle = {}
end

function whistle.reset_player(data, player)
  local tag = support.tag(player)

  data.whistle[tag] = 0
end

function reveal_dungeon()
  local room = Game():GetRoom()
  local dungeon_rock_index = room:GetDungeonRockIdx()

  if dungeon_rock_index < 0 then
    return false
  end

  local grid_entity = room:GetGridEntity(dungeon_rock_index)
  if not grid_entity then
    return false
  end

  local grid_rock_entity = grid_entity:ToRock()
  if not grid_rock_entity then
    return false
  end

  if grid_rock_entity:GetType() ~= GridEntityType.GRID_ROCK then
    return false
  end

  SFXManager():Play(whistle_secret_sound_id)
  room:DestroyGrid(dungeon_rock_index)
  return true
end

function whistle.use_item(data, item_id, _, player)
  if item_id ~= whistle_id then
    return
  end

  local tag = support.tag(player)

  if data.whistle[tag] > 0 then
    return
  end

  SFXManager():Play(whistle_sound_id)
  player:AnimateCollectible(whistle_id, "LiftItem", "PlayerPickup")

  data.whistle[tag] = whistle.tune_delay
end

function whistle.post_perfect_update(data, player)
  local tag = support.tag(player)

  if data.whistle[tag] <= 0 then
    return
  end

  data.whistle[tag] = data.whistle[tag] - 1

  if data.whistle[tag] > 0 then
    return
  end

  player:AnimateCollectible(whistle_id, "HideItem", "PlayerPickup")

  if reveal_dungeon() then
    return
  end

  local position = player.Position
  position.X = -64

  local entity = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, whistle_projectile_id, 0, position, Vector(12, 0), player)
  local projectile = entity:ToProjectile()

  projectile:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
  projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
  projectile:AddProjectileFlags(ProjectileFlags.ANY_HEIGHT_ENTITY_HIT)

  local sprite = projectile:GetSprite()
  sprite:Play(sprite:GetDefaultAnimation(), true)
  sprite.Color = Color.Default

  projectile.FallingSpeed = 0.0
  projectile.FallingAccel = -0.1
end

function whistle.pre_projectile_collision(data, projectile, collider)
  if projectile.Variant ~= whistle_projectile_id then
    return
  end

  local player = collider:ToPlayer()

  if not player then
    local npc = collider:ToNPC()

    if not npc then
      return false
    end

    if npc:IsBoss() then
      return false
    end

    npc:Kill()
    return false
  end

  player:AnimateTeleport(true)
  Game():MoveToRandomRoom(false, Random(), player)
  return true
end
