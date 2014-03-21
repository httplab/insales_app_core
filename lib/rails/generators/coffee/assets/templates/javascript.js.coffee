#
# FIXME: Удалить ненужные экшены, или удалить файл, если он не используется.
#
@Styx.Initializers.<%= class_name.gsub('::', '') %> =
  initialize: ->
    false

  index: (data) ->
    false

  show: (data) ->
    false

  new: (data) ->
    false

  edit: (data) ->
    false
