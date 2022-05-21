local support = {
  PoopSubType = {
    REGULAR = 0,
    BLOOD   = 1,
    CORNY   = 2,
    GOLDEN  = 3,
    RAINBOW = 4,
    BLACK   = 5,
    HOLY    = 6,
  }
}

function support.print(message)
  local parameter_type = type(message)
  if parameter_type == "string" then
    Isaac.ConsoleOutput("[Moriah] "..message.."\n")
  end
end

function support.contains(table, search)
  for _, value in ipairs(table) do
      if value == search then
          return true
      end
  end

  return false
end

function support.merge(base, addition)
  for key, value in pairs(addition) do
    base[key] = value
  end
end

function support.tag(player)
  return "p."..player.ControllerIndex
end

function support.random_seed()
  local seed = Random()

  if seed <= 0 then
    return 1
  end

  return seed
end

function support.create_random_generator()
  local shift_index = 35
  local seed = Random()
  if seed < 1 then
    seed = 1
  end

  local rng = RNG()
  rng:SetSeed(seed, shift_index)

  return rng
end

function support.check_familiar(player, familiar_variant_id, familiar_count, source_collectible_id)
  local item_config = Isaac.GetItemConfig():GetCollectible(source_collectible_id)

  player:CheckFamiliar(familiar_variant_id, familiar_count, support.create_random_generator(), item_config)
end

support.print("Loaded moriah.support")
