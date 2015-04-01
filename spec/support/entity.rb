def entity_to_hash(entity)
  JSON.parse(entity.to_json)
end
