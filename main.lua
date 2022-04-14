Moriah = RegisterMod("Moriah", 1512)

local mod = Moriah

local lunchbox_id = Isaac.GetItemIdByName("Lunchbox")

function Moriah:use_lunchbox()
  local player = Isaac.GetPlayer()
  local active_item = player:GetActiveItem()

  Isaac.RenderText(active_item, 50, 30, 1, 1, 1, 255)
end

Moriah:AddCallback(ModCallbacks.MC_USE_ITEM, Moriah.use_lunchbox, lunchbox_id)
