###
# Load files, configure, and ...
###
handler = require('zappa').app ->
  @include 'src/init'
  
  @include 'controller/server/routing'
  @include 'controller/shared/main'
  
  @include 'helper/map'
  
  @include 'views/layout'


# ... start the server!
handler.app.listen handler.config.PORT
console.log "ColorDefence server listening on port " + handler.config.PORT
