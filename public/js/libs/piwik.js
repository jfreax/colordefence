var pkBaseURL = (("https:" == document.location.protocol) ? "https://piwik.jdsoft.de/" : "http://piwik.jdsoft.de/");
document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));

try {
  var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", 3);
  piwikTracker.trackPageView();
  piwikTracker.enableLinkTracking();
} catch( err ) {
  
}


