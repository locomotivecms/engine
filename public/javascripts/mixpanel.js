var mpq = [];
mpq.push(["init", _bushido_metrics_token]);
(function() {
var mp = document.createElement("script"); mp.type = "text/javascript"; mp.async = true;
mp.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + "//api.mixpanel.com/site_media/js/api/mixpanel.js";
var s = document.getElementsByTagName("script")[0]; s.parentNode.insertBefore(mp, s);
})();

$(function(){
  var section = $('body')[0].className;
  
  var props = {
    app: window._bushido_app
    ,claimed: window._bushido_claimed
  };

  mpq.push(["track_links", $('div#header h1 a.single'), 'big site name header click', props]);
  mpq.push(["track_links", $('li.contents a'), "Contents", props]);
  mpq.push(["track_links", $('li.assets a'), "Assets", props]);
  mpq.push(["track_links", $('li.settings a'), "Settings", props]);


  $('body.contents div#submenu li:first').each(function(){
    var $this = $(this);
    $this.bind('mouseover', function(){
      //mpmetrics.track("pages hover");
      mpq.push(["track", "pages hover", props]);
    });

    // mpmetrics.track_links($this.find('div.header a'), "pages popup new item");
    // mpmetrics.track_links($this.find('div.inner a'), "pages popup inner links");
  });

  $('body.contents div#submenu li:not(:first)').each(function(){
    var $this = $(this);
    $this.bind('mouseover', function(){
      //mpmetrics.track("model hover");
      mpq.push(["track", "model hover", props]);
    });

    // mpmetrics.track_links($this.find('div.header a'), "model popup new item");
    // mpmetrics.track_links($this.find('div.inner a'), "model popup inner links");
  });

  $('img.toggler').each(function(){
    var $this = $(this);
    $this.bind('click', function(){
      mpq.push(["track", "hiearchy toggler click", props]);
    });
  })

  $('body.contents a.remove').each(function(){
    var $this = $(this);
    $this.bind('click', function(){
      mpq.push(["track", "page trash click", props]);
    });
  });

  $('body.assets button span:contains(Create)').bind('click', function(){
    mpq.push(["track", "asset create", props]);
  });

  $('body.contents button span:contains(Create)').bind('click', function(){
    mpq.push(["track", "content create", props]);
  });

  $('fieldset span').each(function(){
    var $this = $(this);
      
    $this.bind('click', function(){
      var $content = $this.parent().next('ol')
          ,state = ($content.is(':visible') === true) ? 'close' : 'open';
      mpq.push(["track", section+ " - "+$this.text()+" click to "+state, props]);
    });
  });

  $('input[type="text"]').each(function(){
    var $this = $(this);
    $this.bind('change', function(){
      mpq.push(["track", section+ ' input '+$this.attr('name')+ " change" ,props]);
    });
  });

  $('h2 a.editable').bind('click', function(){
    mpq.push(["track", "editable title click" ,props]);
  });

});