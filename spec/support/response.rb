def parsed_response
  parse_json(last_response.body)
end

def parse_json(response)
  JSON.parse(response)
end
