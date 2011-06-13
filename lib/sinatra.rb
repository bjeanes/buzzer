Sinatra::Delegator.delegate :routes

def any(route, options = {}, &block)
  route = get(route, &block)

  (routes["POST"]   ||= []).push(route)
  (routes["PUT"]    ||= []).push(route)
  (routes["DELETE"] ||= []).push(route)
end

