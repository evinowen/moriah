local plant_id = Isaac.GetItemIdByName("Plant")

local plant_familiar_id = Isaac.GetEntityVariantByName("Plant")

local plant = {}

function plant.stage(data)
  data.pots = {}
end

function plant.initalize_player(data, player)
  local tag = support.tag(player)

  data.pots[tag] = {}
end

function plant.evaluate_cache(data, player, flag)
  if flag == CacheFlag.CACHE_FAMILIARS then
    if player:HasCollectible(plant_id) then
      local count = player:GetCollectibleNum(plant_id) + player:GetEffects():GetCollectibleEffectNum(plant_id)
      support.check_familiar(player, plant_familiar_id, count, plant_id)
    end
  end
end

function plant.familiar_init(data, familiar)
  if familiar.Variant ~= plant_familiar_id then
    return
  end

  familiar.IsFollower = true
end

function plant.familiar_update(data, familiar)
  if familiar.Variant ~= plant_familiar_id then
    return
  end

  familiar:FollowParent()

  local player = familiar.Player
  local tag = support.tag(player)
  local pot_key = "f".. familiar.InitSeed

  if data.pots[tag][pot_key] == nil then
    data.pots[tag][pot_key] = {
      entity = familiar,
      water = 0.0,
      stomach = 0.0,
      stage = -1
    }
  else
    local sprite = familiar:GetSprite()

    local stage = data.pots[tag][pot_key].stage
    if stage == -1 then
      sprite:Play("Pot")
    elseif stage == 0 then
      sprite:Play("Bud")
    elseif stage == 1 then
      if not sprite:IsPlaying("FlowerPollinate") then
        sprite:Play("Flower")
      elseif sprite:IsFinished("FlowerPollinate") then
        sprite:Play("Flower")
      end
    elseif stage == 2 then
      if not sprite:IsPlaying("EaterGulp") then
        sprite:Play("Eater")
      elseif sprite:IsFinished("EaterGulp") then
        sprite:Play("Eater")
      end
    elseif stage == 3 then
      if data.pots[tag][pot_key].stomach > 0 then
        sprite:Play("DripperDrip")
        data.pots[tag][pot_key].stomach = data.pots[tag][pot_key].stomach - 0.02
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, familiar.Position, Vector.Zero, familiar)
      else
        sprite:Play("Dripper")
        data.pots[tag][pot_key].stomach = 0
      end
    end
  end
end


function plant.pre_projectile_collision(data, projectile, collider)
  local familiar = collider:ToFamiliar()

  if not familiar then
    return
  end

  if familiar.Variant ~= plant_familiar_id then
    return
  end

  local player = familiar.Player

  if not player then
    return
  end

  local tag = support.tag(player)
  local pot_key = "f".. familiar.InitSeed
  local sprite = familiar:GetSprite()

  if data.pots[tag][pot_key].water < 10 then
    familiar:SetColor(Color(1, 1, 1, 1, 1, 1, 1), 15, 1, true, false)
    data.pots[tag][pot_key].water = data.pots[tag][pot_key].water + 1

    if data.pots[tag][pot_key].water >= 10 then
      local number = Random() % 4
      if number == 1 then
        data.pots[tag][pot_key].stage = 1
      elseif number == 2 then
        data.pots[tag][pot_key].stage = 2
      elseif number == 3 then
        data.pots[tag][pot_key].stage = 3
      else
        data.pots[tag][pot_key].water = data.pots[tag][pot_key].water - 2
      end
    elseif data.pots[tag][pot_key].water >= 5 then
      data.pots[tag][pot_key].stage = 0
    else
      data.pots[tag][pot_key].stage = -1
    end
  else
    data.pots[tag][pot_key].stomach = data.pots[tag][pot_key].stomach + 1.0
    familiar:SetColor(Color(1, 1, 1, 1, 0.25, 0.25, 0.25), 15, 1, true, false)

    if data.pots[tag][pot_key].stage == 1 then
      sprite:Play("FlowerPollinate", true)
      local drips = Random() % 6
      for i = 0, drips - 1 do
        local direction = projectile.Velocity:Rotated((Random() % 120) - 16) * 0.5
        local honey = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, Random() % 6, familiar.Position, direction, familiar)
        honey:SetColor(Color(1, 0.5, 0, 1, 0.25, 0.25, 0.25), -1, 1, false, false)
      end

      for i = 0, 2 do
        local entity = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.LOST_CONTACT, 0, familiar.Position, projectile.Velocity:Rotated(15 * (i - 1)), familiar)
        local tear = entity:ToTear()
        tear:SetColor(Color(1, 0.5, 0, 1, 0.25, 0.25, 0.25), -1, 1, false, false)
        tear.Scale = 0.25
      end
    elseif data.pots[tag][pot_key].stage == 2 then
      sprite:Play("EaterGulp", true)
      if data.pots[tag][pot_key].stomach >= 3 then
        data.pots[tag][pot_key].stomach = 0
        player:AddBlueFlies(1, familiar.Position, familiar)
      end
    elseif data.pots[tag][pot_key].stage == 3 then
    end
  end

  projectile:Kill()
end
