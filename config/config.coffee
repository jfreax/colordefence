###
# Config
###
@include = ->
  @config = {
  
      ## CHANGE HERE ##
      
      coffeeDir: 'controller/client'
      publicJSDir: 'public/js'

      PORT: 3008
      
      ## UP TO HERE ##

    }
    
  @include "./config/db"