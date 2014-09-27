###
# Request handler
###

@include = ->
  handler = this
  
  @get '/': ->
    @render 'index',
      title: "JDSoft: ColorDefence",
      stylesheets: ["css/style"],
      scripts: ["/zappa/jquery", "/zappa/zappa", "/shared", "js/libs/ocanvas/ocanvas-2.0.0", "/js/game"]

