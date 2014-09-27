###
# Layout file for every view
###
@include = ->
  @view layout: ->
    doctype 5
    html ->
      head ->
        title @title if @title
        
        meta name:"description", content:""
        meta name:"author", content:""
        
        #<!-- Mobile viewport optimized: j.mp/bplateviewport -->
        meta name:"viewport", content:"width=device-width,initial-scale=1"
        
      body style:"background-color: #000000;", ->
        div id:"main", role:"main", -> @body
        
        
        if @stylesheets
          for s in @stylesheets
            link rel: 'stylesheet', href: s + '.css'
        link(rel: 'stylesheet', href: @stylesheet + '.css') if @stylesheet

        
        style @style if @style
        if @scripts
          for s in @scripts
            script src: s + '.js'
        script src: @script + '.js' if @script

#       '<!-- Piwik -->
#         <script type="text/javascript">
#         var pkBaseURL = (("https:" == document.location.protocol) ? "https://piwik.jdsoft.de/" : "http://piwik.jdsoft.de/");
#         document.write(unescape("%3Cscript src=\'" + pkBaseURL + "piwik.js\' type=\'text/javascript\'%3E%3C/script%3E"));
#         </script><script type="text/javascript">
#         try {
#           var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", 3);
#           piwikTracker.trackPageView();
#           piwikTracker.enableLinkTracking();
#           } catch( err ) {}
#           </script><noscript><p><img src="http://piwik.jdsoft.de/piwik.php?idsite=3" style="border:0" alt="" /></p></noscript>
#           <!-- End Piwik Tracking Code -->'
