local tradesman = {
  card = Isaac.GetCardIdByName("tradesman"),
  tears = 100,
  items = {
    butchers_apron = Isaac.GetItemIdByName("Butcher's Apron"),
    bakers_apron = Isaac.GetItemIdByName("Baker's Apron"),
    chandlers_apron = Isaac.GetItemIdByName("Chandler's Apron"),
  },
  familiars = {
    butchers_cleaver = Isaac.GetEntityVariantByName("Butcher's Cleaver"),
  },
  animations = {
    tradesman = Isaac.GetCostumeIdByPath("gfx/characters/tradesman.anm2"),
    front = {
      butcher = Isaac.GetCostumeIdByPath("gfx/characters/butchers.apron.anm2"),
      baker = Isaac.GetCostumeIdByPath("gfx/characters/bakers.apron.anm2"),
      chandler = Isaac.GetCostumeIdByPath("gfx/characters/chandlers.apron.anm2"),
    },
    back = {
      butcher = Isaac.GetCostumeIdByPath("gfx/characters/butchers.apron.back.anm2"),
      baker = Isaac.GetCostumeIdByPath("gfx/characters/bakers.apron.back.anm2"),
      chandler = Isaac.GetCostumeIdByPath("gfx/characters/chandlers.apron.back.anm2"),
    }
  }
}

function tradesman.stage(data)
  data.tradesmen = {}
end

function tradesman.initalize_player(data, player)
  local tag = support.tag(player)

  data.tradesmen[tag] = {
    realized = false,
    transformed = false,
    front = 0,
    back = 0,
  }
end

function tradesman.evaluate_cache(data, player, flag)
  if flag == CacheFlag.CACHE_WEAPON then
    return tradesman.evaluate_cache_weapon(data, player)
  end

  if flag == CacheFlag.CACHE_FLYING then
    return tradesman.evaluate_cache_flying(data, player)
  end

  if flag == CacheFlag.CACHE_FAMILIARS then
    return tradesman.evaluate_cache_familiars(data, player)
  end

  if flag == CacheFlag.CACHE_TEARFLAG then
    if data.tradesmen[tag].realized then
      player.TearFlags = player.TearFlags | tradesmen.tears
    end
  end
end

function tradesman.evaluate_cache_weapon(data, player)
  local tag = support.tag(player)
  local count = 0
  local is_realized = data.tradesmen[tag].realized

  if player:HasCollectible(tradesman.items.butchers_apron) then
    if data.tradesmen[tag].front == 0 and data.tradesmen[tag].back ~= tradesman.animations.back.butcher then
      data.tradesmen[tag].front = tradesman.animations.front.butcher
    elseif data.tradesmen[tag].back == 0 and data.tradesmen[tag].front ~= tradesman.animations.front.butcher then
      data.tradesmen[tag].back = tradesman.animations.back.butcher
    end

    count = count + 1
  else
    if data.tradesmen[tag].front == tradesman.animations.front.butcher then
      data.tradesmen[tag].front = 0
    elseif data.tradesmen[tag].back == tradesman.animations.back.butcher then
      data.tradesmen[tag].back = 0
    end

    player:TryRemoveNullCostume(tradesman.animations.front.butcher)
    player:TryRemoveNullCostume(tradesman.animations.back.butcher)
  end

  if player:HasCollectible(tradesman.items.bakers_apron) then
    if data.tradesmen[tag].front == 0 and data.tradesmen[tag].back ~= tradesman.animations.back.baker then
      data.tradesmen[tag].front = tradesman.animations.front.baker
    elseif data.tradesmen[tag].back == 0 and data.tradesmen[tag].front ~= tradesman.animations.front.baker then
      data.tradesmen[tag].back = tradesman.animations.back.baker
    end

    count = count + 1
  else
    if data.tradesmen[tag].front == tradesman.animations.front.baker then
      data.tradesmen[tag].front = 0
    elseif data.tradesmen[tag].back == tradesman.animations.back.baker then
      data.tradesmen[tag].back = 0
    end

    player:TryRemoveNullCostume(tradesman.animations.front.baker)
    player:TryRemoveNullCostume(tradesman.animations.back.baker)
  end

  if player:HasCollectible(tradesman.items.chandlers_apron) then
    if data.tradesmen[tag].front == 0 and data.tradesmen[tag].back ~= tradesman.animations.back.chandler then
      data.tradesmen[tag].front = tradesman.animations.front.chandler
    elseif data.tradesmen[tag].back == 0 and data.tradesmen[tag].front ~= tradesman.animations.front.chandler then
      data.tradesmen[tag].back = tradesman.animations.back.chandler
    end

    count = count + 1
  else
    if data.tradesmen[tag].front == tradesman.animations.front.chandler then
      data.tradesmen[tag].front = 0
    elseif data.tradesmen[tag].back == tradesman.animations.back.chandler then
      data.tradesmen[tag].back = 0
    end

    player:TryRemoveNullCostume(tradesman.animations.front.chandler)
    player:TryRemoveNullCostume(tradesman.animations.back.chandler)
  end

  if count >= 3 then
    data.tradesmen[tag].realized = true
  else
    data.tradesmen[tag].realized = false

    player:TryRemoveNullCostume(tradesman.animations.tradesman)

    if data.tradesmen[tag].front ~= 0 then
      player:AddNullCostume(data.tradesmen[tag].front)
    end

    if data.tradesmen[tag].back ~= 0 then
      player:AddNullCostume(data.tradesmen[tag].back)
    end
  end

  if data.tradesmen[tag].realized ~= is_realized then
    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    player:EvaluateItems()
  end
end

function tradesman.post_player_update(data, player)
  local tag = support.tag(player)

  if not data.tradesmen[tag].realized then
    return
  end

  if data.tradesmen[tag].transformed then
    return
  end

  if not player:IsExtraAnimationFinished() then
    return
  end

  local hud = Game():GetHUD()
  hud:ShowItemText("Tradesman", "Butcher, Baker, Candlestick Maker")

  player:AddNullCostume(tradesman.animations.tradesman)

  data.tradesmen[tag].transformed = true
end

function tradesman.use_card(data, card_id, player)
  if card_id ~= tradesman.card then
    return
  end

  player:TryRemoveNullCostume(tradesman.animations.front.butcher)
  player:TryRemoveNullCostume(tradesman.animations.back.butcher)
  player:TryRemoveNullCostume(tradesman.animations.front.baker)
  player:TryRemoveNullCostume(tradesman.animations.back.baker)
  player:TryRemoveNullCostume(tradesman.animations.front.chandler)
  player:TryRemoveNullCostume(tradesman.animations.back.chandler)

  player:AddNullCostume(tradesman.animations.tradesman)
end

function tradesman.evaluate_cache_flying(data, player)
  local tag = support.tag(player)

  if data.tradesmen[tag].realized == true then
    player.CanFly = true
  end
end

function tradesman.evaluate_cache_familiars(data, player)
  local tag = support.tag(player)
  local count = 0

  if data.tradesmen[tag].realized == true then
    count = 1
  end

  support.check_familiar(player, tradesman.familiars.butchers_cleaver, count)
end

function tradesman.post_tear_init(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if not player then
    return
  end

  local tag = support.tag(player)

  if data.tradesmen[tag].realized then
    tear:ChangeVariant(TearVariant.FIRE_MIND)
    tear:Update()

    local sprite = tear:GetSprite()
    sprite.Scale = Vector(0, 0)
    sprite:Update()
  end
end

function tradesman.post_tear_update(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if not player then
    return
  end

  local tag = support.tag(player)

  if data.tradesmen[tag].realized then
    tear:AddTearFlags(TearFlags.TEAR_BURN)
  end
end

function tradesman.fire(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if not player then
    return
  end

  local tag = support.tag(player)

  if data.tradesmen[tag].realized then
    -- Order of Operations Important!
    tear.FallingAcceleration = 1.2
    tear.FallingSpeed = -6.0
    tear.Velocity = tear.Velocity * 0.5
    tear.Height = -80

    local chance = 100
    for i = 0, 5 do
      if Random() % 100 <= chance then
        chance = chance - 20

        local entity = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, player.Position, tear.Velocity:Rotated((Random() % 120) - 60) * 0.25, player)
        local tear_wax = entity:ToTear()

        tear_wax.CollisionDamage = player.Damage * 0.5
        tear_wax.Scale = (50 - (Random() % 25)) / 100.0

        tear_wax.Height = -40
        tear_wax.FallingSpeed = -12
        tear_wax.FallingAcceleration = 3

        tear_wax:SetColor(Color(1, 1, 0.95, 1, 0.75, 0.75, 0.75), -1, 1, false, false)
      end
    end
  end
end


function tradesman.familiar_init(data, familiar)
  if familiar.Variant ~= tradesman.familiars.butchers_cleaver then
    return
  end

  familiar:AddToOrbit(1)
  familiar.OrbitDistance = Vector(100,50)
end

function tradesman.familiar_update(data, familiar)
  if familiar.Variant ~= tradesman.familiars.butchers_cleaver then
    return
  end

  local player = familiar.Player

	familiar.OrbitDistance = Vector(40, 30)
	familiar.OrbitLayer = 98
	familiar.OrbitSpeed = 0.1
	familiar.FireCooldown = 32
	familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position
end

function tradesman.pre_projectile_collision(data, projectile, collider)
  local familiar = collider:ToFamiliar()

  if not familiar then
    return
  end

  if familiar.Variant ~= tradesman.familiars.butchers_cleaver then
    return
  end

  local player = familiar.Player

  if not player then
    return
  end

  projectile:Kill()
end
