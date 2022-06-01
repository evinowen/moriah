local fishbowl_id = Isaac.GetItemIdByName("Fishbowl")

local fishbowl = {
  id_table = { fishbowl_id },
  animations = {
    empty = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.empty.anm2"),
    black = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.black.anm2"),
    blood = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.blood.anm2"),
    blue = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.blue.anm2"),
    brimstone = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.brimstone.anm2"),
    brown = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.brown.anm2"),
    green = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.green.anm2"),
    milk = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.milk.anm2"),
    mysterious = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.mysterious.anm2"),
    pennies = Isaac.GetCostumeIdByPath("gfx/characters/fishbowl.pennies.anm2"),
  }
}

function fishbowl.evaluate_cache(data, player, flag)
  if flag == CacheFlag.CACHE_FLYING then
    if player:HasCollectible(fishbowl_id) then
      player.CanFly = true
    end
  end

  if flag == CacheFlag.CACHE_TEARCOLOR then
    if not player:HasCollectible(fishbowl_id) then
      return
    end

    player:TryRemoveNullCostume(fishbowl.animations.empty)
    player:TryRemoveNullCostume(fishbowl.animations.black)
    player:TryRemoveNullCostume(fishbowl.animations.blood)
    player:TryRemoveNullCostume(fishbowl.animations.blue)
    player:TryRemoveNullCostume(fishbowl.animations.brimstone)
    player:TryRemoveNullCostume(fishbowl.animations.brown)
    player:TryRemoveNullCostume(fishbowl.animations.green)
    player:TryRemoveNullCostume(fishbowl.animations.milk)
    player:TryRemoveNullCostume(fishbowl.animations.mysterious)
    player:TryRemoveNullCostume(fishbowl.animations.pennies)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
      player:AddNullCostume(fishbowl.animations.brimstone)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then
      player:AddNullCostume(fishbowl.animations.pennies)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_8_INCH_NAILS)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_DOVE)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_ONION)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_OUIJA_BOARD)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_PUPULA_DUPLEX)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_TINY_PLANET) then
      player:AddNullCostume(fishbowl.animations.empty)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID) then
      player:AddNullCostume(fishbowl.animations.mysterious)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_EXPLOSIVO)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA) then
      player:AddNullCostume(fishbowl.animations.black)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO) then
      player:AddNullCostume(fishbowl.animations.green)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
      player:AddNullCostume(fishbowl.animations.milk)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR) then
      player:AddNullCostume(fishbowl.animations.blood)
    else
      player:AddNullCostume(fishbowl.animations.blue)
    end
  end
end

function fishbowl.fire(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if player and player:HasCollectible(fishbowl_id) then
    if player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE) then
      return
    end
    if tear:HasTearFlags(TearFlags.TEAR_SPECTRAL) then
      return
    end

    local damage = tear.BaseDamage
    local color = tear:GetColor()
    tear:Remove()

    if tear.Variant == TearVariant.TOOTH
    or tear.Variant == TearVariant.SCHYTHE
    or tear.Variant == TearVariant.NAIL
    or tear.Variant == TearVariant.COIN then
    else
      local puddle_entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, player.Position, Vector.Zero, player)
      local puddle_effect = puddle_entity:ToEffect()
      puddle_effect.Scale = damage / 5.0

      puddle_effect:SetColor(color, -1, 1, false, false)
      puddle_effect:Update()
    end
  end
end

function fishbowl.pre_projectile_collision(data, projectile, collider)
  local player = collider:ToPlayer()

  if player and player:HasCollectible(fishbowl_id) then
    projectile.Velocity = projectile.Velocity * -0.9
    return true
  end
end
