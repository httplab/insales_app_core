@Styx.Initializers.<%= class_name.gsub('::', '') %> =
  initialize: ->
    console.log 'This will be called in <%= class_name %>#ANY action after <head> was parsed'

  index: (data) ->
    console.log 'This will be called in <%= class_name %>#index action after <head> was parsed'

  show: (data) ->
    $ ->
      console.log 'This will be called in <%= class_name %>#show action after the page was loaded'

  new: (data) ->
    $ ->
      console.log 'This will be called in <%= class_name %>#new action after the page was loaded'

  edit: (data) ->
    $ ->
      console.log 'This will be called in <%= class_name %>#edit action after the page was loaded'
