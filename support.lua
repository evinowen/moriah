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

support.print("Loaded moriah.support")
return support
