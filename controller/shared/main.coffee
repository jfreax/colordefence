@include = ->
  ###
  # Shared
  ###
  @shared '/shared.js': ->
    handler = this
    root = window ? global

    