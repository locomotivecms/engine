Handlebars.registerHelper 'each_with_index', (context, block) ->
  ret = ""

  for num in context
    data = context[num]
    data._index = num
    ret = ret + block(data)

  ret