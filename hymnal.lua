local support = require("support")

local hymnal_id = Isaac.GetItemIdByName("Hymnal")

local hymnal = {}

function hymnal.stage(data)
  data.hymnal = {}
end

function hymnal.reset_player(data, player)
  local tag = support.tag(player)

  data.hymnal[tag] = 0
end

function hymnal.use_item(data, item_id, _, player)
  if item_id ~= hymnal_id then
    return
  end

  local tag = support.tag(player)

  player:AnimateCollectible(hymnal_id, "LiftItem", "PlayerPickup")
  Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, player.Position, Vector.Zero, player)
  data.hymnal[tag] = 20
end

function hymnal.post_perfect_update(data, player)
  local tag = support.tag(player)

  if data.hymnal[tag] > 0 then
    data.hymnal[tag] = data.hymnal[tag] - 1

    if data.hymnal[tag] <= 0 then
      local room = Game():GetRoom()
      local room_entities = room:GetEntities()

      for i = 0, #room_entities - 1 do
          local entity = room_entities:Get(i)
          local entity_npc = entity:ToNPC()

          if entity_npc then
            if entity_npc:IsBoss() then
              entity_npc:AddFreeze(EntityRef(player), 300)
              entity_npc:SetColor(Color(1, 1, 1, 1, 0.2, 0.2, 0.25), -1, 1, false, false)
            else
              entity_npc:AddFreeze(EntityRef(player), 600)
              entity_npc:SetColor(Color(1, 1, 1, 1, 0.2, 0.25, 0.3), -1, 1, false, false)
            end
          end
      end

      player:AnimateCollectible(hymnal_id, "HideItem", "PlayerPickup")
    end
  end
end


return hymnal
