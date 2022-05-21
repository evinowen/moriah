local bowtie_id = Isaac.GetItemIdByName("Bow Tie")

local bowtie = {
  id_table = { bowtie_id }
}

function bowtie.fire(data, tear)
  local entity = tear.SpawnerEntity
  local player = entity:ToPlayer()

  if player and player:HasCollectible(bowtie_id) then
    if Random() % 10 <= 1 then
      tear:AddTearFlags(TearFlags.TEAR_CHARM)
      tear:SetColor(Color(1, 0.5, 0.75, 1, 0.1, 0.1, 0.1), -1, 1, false, false)
    end
  end
end
