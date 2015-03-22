def parsed_response
  parsed_response = parse_json(last_response.body)
  if parsed_response.respond_to?(:with_indifferent_access)
    parsed_response.with_indifferent_access
  else
    parsed_response
  end
end

def parse_json(response)
  JSON.parse(response)
end
