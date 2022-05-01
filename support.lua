local support = {}

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

support.print("Loaded moriah.support")
return support
