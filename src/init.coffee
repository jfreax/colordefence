@include = ->
  @include "./config/config"
  
  ###
  # Open db connection
  ###
  @redis = require 'redis'
  @db = @redis.createClient()
  @db.select @config.db.DB_IDX


  ###
  # CoffeeScript
  ###
  require 'coffee-script'


  ##
  # Configure zappa
  ##
  @use @express.compiler(src: @config.coffeeDir, dest: @config.publicJSDir, enable: ['coffeescript'])
  @use @express.bodyParser()
  
  @enable 'serve jquery', 'serve sammy', 'serve zappa'
  @use 'static'
  
  @configure
    development: => @use errorHandler: {dumpExceptions: on, showStack: on}
    production: => @use 'errorHandler'
