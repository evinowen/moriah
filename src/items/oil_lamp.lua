local oil_lamp_id = Isaac.GetItemIdByName("Oil Lamp")

local oil_lamp = {
  id_table = { oil_lamp_id },
  familiar = Isaac.GetEntityVariantByName("Oil Lamp"),
  frames = {
    throw = 50,
    rejoin = 50,
    cooldown = 50,
  },
  velocity = 8.0,
  fire_type = {
    NONE = -1,
    YELLOW = 0,
    RED = 1,
    BLUE = 2,
    PURPLE = 3,
    WHITE = 4,
  }
}

function oil_lamp.stage(data)
  data.oil_lamps = {}
end

function oil_lamp.initalize_player(data, player)
  local tag = support.tag(player)

  data.oil_lamps[tag] = {}
end

function oil_lamp.evaluate_cache(data, player, flag)
  if flag == CacheFlag.CACHE_FAMILIARS then
    if player:HasCollectible(oil_lamp_id) then
      local count = player:GetCollectibleNum(oil_lamp_id) + player:GetEffects():GetCollectibleEffectNum(oil_lamp_id)
      support.check_familiar(player, oil_lamp.familiar, count, oil_lamp_id)
    end
  end
end

function oil_lamp.familiar_init(data, familiar)
  if familiar.Variant ~= oil_lamp.familiar then
    return
  end

  familiar:AddToFollowers()
end

function oil_lamp.familiar_update(data, familiar)
  if familiar.Variant ~= oil_lamp.familiar then
    return
  end

  local player = familiar.Player
  local tag = support.tag(player)
  local lamp_key = "f".. familiar.InitSeed

  if data.oil_lamps[tag][lamp_key] == nil then
    data.oil_lamps[tag][lamp_key] = {
      fire = oil_lamp.fire_type.NONE,
      thrown = false,
      frames = 0,
      follow = Vector.Zero,
      cooldown = oil_lamp.frames.cooldown,
    }
  end

  local throw = false

  if data.oil_lamps[tag][lamp_key].thrown then
    data.oil_lamps[tag][lamp_key].frames = data.oil_lamps[tag][lamp_key].frames - 1

    if data.oil_lamps[tag][lamp_key].frames > 0 then
      familiar.Velocity = data.oil_lamps[tag][lamp_key].follow - familiar.Position

      if familiar.Velocity:LengthSquared() > oil_lamp.velocity * oil_lamp.velocity then
        familiar.Velocity = familiar.Velocity:Normalized() * oil_lamp.velocity
      end
    elseif data.oil_lamps[tag][lamp_key].frames == 0 then
      familiar:AddToFollowers()
    else
      familiar:FollowParent()

      if data.oil_lamps[tag][lamp_key].frames <= oil_lamp.frames.rejoin * -1 then
        data.oil_lamps[tag][lamp_key].thrown = false
        data.oil_lamps[tag][lamp_key].follow = Vector.Zero
      end
    end
  else
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
      data.oil_lamps[tag][lamp_key].follow = familiar.Position - Vector(256, 0)
      throw = true
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
      data.oil_lamps[tag][lamp_key].follow = familiar.Position + Vector(256, 0)
      throw = true
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
      data.oil_lamps[tag][lamp_key].follow = familiar.Position - Vector(0, 256)
      throw = true
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
      data.oil_lamps[tag][lamp_key].follow = familiar.Position + Vector(0, 256)
      throw = true
    else
      if data.oil_lamps[tag][lamp_key].cooldown > 0 then
        data.oil_lamps[tag][lamp_key].cooldown = data.oil_lamps[tag][lamp_key].cooldown - 1
      else
        familiar.Target = nil
        familiar.ShootDirection = Direction.NO_DIRECTION
        familiar:PickEnemyTarget(2048, 0, 1 | 16, Vector.One, 180)
        if familiar.Target then
          local direction = (familiar.Target.Position - familiar.Position):Normalized()
          if data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.RED then
            local entity = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, familiar.Position, direction * 3, familiar)

            local tear = entity:ToTear()
            tear.Scale = 0.5
            tear.Height = -10
            tear.FallingSpeed = 0
            tear.FallingAcceleration = -0.1
          elseif data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.PURPLE then
            local entity = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, familiar.Position, direction * 3, familiar)

            local tear = entity:ToTear()
            tear.Scale = 0.5
            tear.Height = -10
            tear.FallingSpeed = 0
            tear.FallingAcceleration = -0.1

            tear:SetColor(Color(0.5, 0, 0.75, 1, 0.1, 0.1, 0.1), -1, 1, false, false)
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
          end
        end

        data.oil_lamps[tag][lamp_key].cooldown = oil_lamp.frames.cooldown
      end

    end

    if throw then
      data.oil_lamps[tag][lamp_key].thrown = true
      data.oil_lamps[tag][lamp_key].frames = oil_lamp.frames.throw

      familiar:RemoveFromFollowers()
    elseif not data.oil_lamps[tag][lamp_key].thrown then
      familiar:FollowParent()
    end
  end
end

function oil_lamp.pre_projectile_collision(data, projectile, collider)
  local familiar = collider:ToFamiliar()

  if not familiar then
    return
  end

  if familiar.Variant ~= oil_lamp.familiar then
    return
  end

  local player = familiar.Player

  if not player then
    return
  end

  local tag = support.tag(player)
  local lamp_key = "f".. familiar.InitSeed

  familiar:SetColor(Color(1, 1, 1, 1, 0.2, 0.2, 0.2), 15, 1, true, true)
  projectile:Kill()

  if data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.YELLOW
  or data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.RED then
    oil_lamp.extinguish_lamp(data, familiar)
  end
end

function oil_lamp.pre_familiar_collision(data, familiar, collider)
  if familiar.Variant ~= oil_lamp.familiar then
    return
  end

  local player = familiar.Player
  local tag = support.tag(player)
  local lamp_key = "f".. familiar.InitSeed

  if data.oil_lamps[tag][lamp_key] == nil then
    return
  end

  if data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.NONE then
    oil_lamp.pre_familiar_collision_empty(data, familiar, collider)
  elseif data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.YELLOW then
    oil_lamp.pre_familiar_collision_fire_yellow(data, familiar, collider)
  elseif data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.RED then
    oil_lamp.pre_familiar_collision_fire_red(data, familiar, collider)
  elseif data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.BLUE then
    oil_lamp.pre_familiar_collision_fire_blue(data, familiar, collider)
  elseif data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.PURPLE then
    oil_lamp.pre_familiar_collision_fire_purple(data, familiar, collider)
  elseif data.oil_lamps[tag][lamp_key].fire == oil_lamp.fire_type.WHITE then
    oil_lamp.pre_familiar_collision_fire_white(data, familiar, collider)
  end
end

function oil_lamp.pre_familiar_collision_empty(data, familiar, collider)
  if oil_lamp.collider_is_fireplace(collider) then
    oil_lamp.light_lamp(data, familiar, collider.Variant)
  end
end

function oil_lamp.pre_familiar_collision_fire_yellow(data, familiar, collider)
  if oil_lamp.collider_is_fireplace(collider) then
    if variant == oil_lamp.fire_type.YELLOW then
      return
    end

    oil_lamp.light_lamp(data, familiar, collider.Variant)
  elseif collider:IsVulnerableEnemy() then
    collider:AddBurn(EntityRef(familiar), 20, 1)
  end
end

function oil_lamp.pre_familiar_collision_fire_red(data, familiar, collider)
  if oil_lamp.collider_is_fireplace(collider) then
    if variant == oil_lamp.fire_type.YELLOW
    or variant == oil_lamp.fire_type.RED then
      return
    end

    oil_lamp.light_lamp(data, familiar, collider.Variant)
  elseif collider:IsVulnerableEnemy() then
    collider:AddBurn(EntityRef(familiar), 40, 1)
  end
end

function oil_lamp.pre_familiar_collision_fire_blue(data, familiar, collider)
  if oil_lamp.collider_is_fireplace(collider) then
    if variant == oil_lamp.fire_type.YELLOW
    or variant == oil_lamp.fire_type.RED
    or variant == oil_lamp.fire_type.BLUE then
      return
    end

    oil_lamp.light_lamp(data, familiar, collider.Variant)
  elseif collider:IsVulnerableEnemy() then
    collider:AddBurn(EntityRef(familiar), 20, 2)
  end
end

function oil_lamp.pre_familiar_collision_fire_purple(data, familiar, collider)
  if oil_lamp.collider_is_fireplace(collider) then
    if variant ~= oil_lamp.fire_type.WHITE then
      return
    end

    oil_lamp.light_lamp(data, familiar, collider.Variant)
  elseif collider:IsVulnerableEnemy() then
    collider:AddBurn(EntityRef(familiar), 40, 2)
  end
end

function oil_lamp.pre_familiar_collision_fire_white(data, familiar, collider)
  if oil_lamp.collider_is_fireplace(collider) then
    collider:Kill()
  elseif collider:IsVulnerableEnemy() then
    collider:AddBurn(EntityRef(familiar), 40, 3)
  end
end

function oil_lamp.collider_is_fireplace(collider)
  if collider.Type ~= EntityType.ENTITY_FIREPLACE then
    return false
  end

  if collider.HitPoints <= 0 then
    return false
  end

  return true
end

function oil_lamp.collider_is_enemy(collider)
  if collider.Type ~= EntityType.ENTITY_FIREPLACE then
    return false
  end

  if collider.HitPoints <= 0 then
    return false
  end

  return true
end

function oil_lamp.light_lamp(data, familiar, variant)
  local player = familiar.Player
  local tag = support.tag(player)
  local lamp_key = "f".. familiar.InitSeed

  data.oil_lamps[tag][lamp_key].fire = variant

  local sprite = familiar:GetSprite()

  if variant == oil_lamp.fire_type.YELLOW then
    sprite:Play("Yellow")
  elseif variant == oil_lamp.fire_type.RED then
    sprite:Play("Red")
  elseif variant == oil_lamp.fire_type.BLUE then
    sprite:Play("Blue")
  elseif variant == oil_lamp.fire_type.PURPLE then
    sprite:Play("Purple")
  elseif variant == oil_lamp.fire_type.WHITE then
    sprite:Play("White")
  end
end

function oil_lamp.extinguish_lamp(data, familiar)
  local player = familiar.Player
  local tag = support.tag(player)
  local lamp_key = "f".. familiar.InitSeed

  data.oil_lamps[tag][lamp_key].fire = oil_lamp.fire_type.NONE

  local sprite = familiar:GetSprite()
  sprite:Play("Empty")

  Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, nil)
  SFXManager():Play(SoundEffect.SOUND_SUMMON_POOF)
end
