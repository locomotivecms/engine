$(document).ready(function(){
  
  /*
  *
  * /admin/pages
  *
  */
  if(window.location.pathname == "/admin/pages"){
    
    $('#new_page_tutorial').click(function(){
      if($('#newpage').length > 0){
        guiders.hideAll();
        guiders.show('newpage');
      }else{
        window.location = "/admin/pages#guider=newpage"
      }
      return false;
    });

    guiders.createGuider({
      attachTo: "#newpage",
      buttons: [{name: "Close", onclick: guiders.hideAll}],
      description: "Click above to make a new page",
      id: "newpage",
      position: 6,
      width: 200,
      title: "Make a new page",
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "Thank you for choosing LocomotiveCMS!, <br /><br />\
      This guide will help you get up and running.\
      We will walk you through some common tasks of LocomotiveCMS.\
      This guide can be reached at any time by clicking the \"Help\" link<br /><br />\
      Lets start by editing a page.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "welcome",
      next: "pagewelcome",
      overlay: true,
      title: "Welcome to Locomotive CMS"
    });
  
    guiders.createGuider({
      attachTo: "#help",
      buttons: [],
      description: "Click 'help' in the future to start these guides",
      id: "welcome",
      next: "pagewelcome",
      position: 6,
      width: 260,
      height: 100,
      title: ""
    });
  
    guiders.createGuider({
      attachTo: "ul.folder:first li",
      buttons: [],
      description: "These are pages. You can click on the page name to edit it.",
      id: "pagepointer",
      next: "editpagewelcome",
      width: 200,
      position: 9,
      title: ""
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "A page is a collection of content on your site that can be reached at a web address <br /></br>\
      For this example we will edit the '"+$('ul.folder:first li a:first').text()+"' page. To do that you would click on the page name.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next - Edit "+$('ul.folder:first li a:first').text()+"", onclick: function(){
                  window.location = $('ul.folder:first li a:first').attr('href') + "#guider=editpagewelcome"
                }
              }],
      id: "pagewelcome",
      next: "editpagewelcome",
      overlay: true,
      title: "What is a page?",
      onShow: function(){
        guiders.show('pagepointer')
      }
    });
    
    guiders.createGuider({
      attachTo: 'li.hoverable:last',
      buttons: [],
      description: "These are models.<br /> You can hover over to edit them.",
      id: "modelpointer",
      next: "editpagewelcome",
      width: 240,
      position: 3,
      title: ""
    });
    
    guiders.createGuider({
      attachTo: 'div.action span',
      buttons: [],
      description: "You can click here to make a new model",
      id: "newmodelpointer",
      next: "editpagewelcome",
      position: 6,
      width: 200,
      title: ""
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "What is a model?<br />\
      The concept of a model within locomotiveCMS is a peice of content that you might reuse through out your site.\
      Some example models could be: Blog posts, Products, Events, Locations, Photos<br /></br />\
      For this next section of the guide. We will edit our Event model. '"+$('.inner:eq(3) li:first a').text()+"' ",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next - Edit an Event", onclick: function(){
                  /*
                  *
                  * This is really britle 
                  *
                  */
                  window.location = $('.inner:eq(3) li:first a').attr('href') + "#guider=editmodelwelcome";
                }}],
      id: "modelwelcome",
      next: "newmodel",
      overlay: true,
      title: "Lets talk about Models...",
      onShow: function(){
        guiders.show("modelpointer");
        guiders.show('newmodelpointer');
      }
    });
    
    guiders.createGuider({
      attachTo: 'li.settings a',
      buttons: [],
      description: "Click this tab to edit your settings.",
      id: "settingspointer",
      position: 3,
      width: 200,
      title: ""
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "LocomotiveCMS has several features that you can adjust in the settings panel. Lets head there now!",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next - Goto Settings", onclick: function(){
                  window.location = $('li.settings a').attr('href') + "#guider=settingseditwelcome";
                }}],
      id: "settingswelcome",
      overlay: true,
      title: "How To Change Your Settings",
      onShow: function(){
        guiders.show("settingspointer");
      }
    });
  
  }
  
  
  /*
  *
  * /admin/pages/edit 
  *
  */
  if(window.location.pathname.match('admin/pages/.+\/edit') != null){
    guiders.createGuider({
      attachTo: "undefined",
      description:     "You are now editing the '"+$('a.editable:first').text()+"' page. Lets start by changing the title of this page.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "editpagewelcome",
      next: "editpagetitle",
      overlay: true,
      title: "Editing A Page"
    });
  
    guiders.createGuider({
      attachTo: "a.editable:first",
      buttons: [],
      title: "",
      id: "editpagetitle",
      next: "greatjob",
      position: 6,
      width: 200,
      height: 100,
      description: "Click here to edit the page title"
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description:     "You just changed the title of this page. Lets continue by editing the page content.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "greatjob",
      next: "savepageedit",
      overlay: true,
      title: "Great Job!"
    });  
    
    // guiders.createGuider({
    //   attachTo: "li.text:first label",
    //   description: "You can edit the content of your page in this text box",
    //   id: "pageeditcontent",
    //   next: "savepageedit",
    //   position: 6,
    //   title: "Edit the content of the page"
    // });
  
    guiders.createGuider({
      buttons: [],
      attachTo: "button.light:last",
      description: "Click this update button to save any changes you've made to the page.",
      id: "savepageedit",
      next: "help",
      position: 12,
      title: "Save Your Work",
      onShow: function(){
        $('form.save-with-shortcut').attr('action', 
        $('form.save-with-shortcut').attr('action')+"#guider=editsavesuccess");
      }
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description:     "Great work! you've update this page. You can review your work by checking out the 'frontend' of the site.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "editsavesuccess",
      next: "viewsite2",
      overlay: true, 
      title: "Page Saved Successfully!"
    });
    
    guiders.createGuider({
      attachTo: "#viewsite_ele",
      buttons: [],
      description: "This will open a new tab in your browser and take you to the 'frontend' of your site. The frontend is what other visitors to your sit will see. Come back to this tab in your browser to continue the guide.",
      id: "viewsite2",
      next: "editfinish",
      position: 6,
      width: 280,
      title: "Click Here To View Your Site",
      onShow: function(){
        console.log("binding click for view site", $('#viewsite_ele'));
        $('#viewsite_ele').bind('click', function(){
          console.log("viewsite click!");
          guiders.next();
          //should probably unbind this to prevent double clicking
        });
      }
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "Congratulations. You've just edited a page using LocomotiveCMS! Moving on, we will now move onto models. Lets return to the admin home.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next - Goto Admin Home", onclick: function(){
                  window.location = "/admin/pages#guider=modelwelcome";
                }}],
      id: "editfinish",
      overlay: true,
      title: "Done editing."
    });
  
  }
  
  /*
  *
  * Content edits
  *
  */
  if(window.location.pathname.match('admin/content_types/events/contents/.+/edit') != null){
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "You are now edting an instance of our event model.\
      Make some changes to this event model and it will be reflected everywhere the data is used throught the site.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "editmodelwelcome",
      next: "savemodel",
      overlay: true,
      title: "Editing an Event model"
    });
    
    guiders.createGuider({
      buttons: [],
      attachTo: "button.light:last",
      description: "Click this update button to save any changes you've made to the page.",
      id: "savemodel",
      position: 12,
      title: "Save Your Work",
      onShow: function(){
        $('form.save-with-shortcut').attr('action', 
        $('form.save-with-shortcut').attr('action')+"#guider=modelsavesuccess");
      }
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "You've Successfully updated this model",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next - Goto Admin Home", onclick: function(){
                  window.location = "/admin/pages#guider=settingswelcome";
                }}],
      id: "modelsavesuccess",
      overlay: true,
      title: "Great Work!"
    });
    
  }
  
  
  /*
  *
  * Settings page
  *
  */
  if(window.location.pathname.match("admin/current_site/edit") != null){
    
    
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "Welcome to the Settings page. Here you can create new user accounts to use LocomotiveCMS, Edit SEO options, and more. We will start by changing the subomain of our site.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "settingseditwelcome",
      next: "editsubdomain",
      overlay: true,
      title: "The Settings Page"
    });
    
    guiders.createGuider({
      attachTo: "#site_subdomain",
      description: "Edit this field to change the subdomain of your site",
      buttons: [],
      id: "editsubdomain",
      next: "settingssave",
      title: '',
      position: 12,
      onShow: function(){
        $('#site_subdomain').bind('change', function(){
          guiders.next();
        });
      }
    });
        
    guiders.createGuider({
      buttons: [],
      attachTo: "button.light:last",
      description: "Click this update button to save any changes you've made to the settings.",
      id: "settingssave",
      position: 12,
      title: "Save Your Work",
      onShow: function(){
        $('form.save-with-shortcut').attr('action', 
        $('form.save-with-shortcut').attr('action')+"#guider=modelsavesuccess");
      }
    });
    
    guiders.createGuider({
      attachTo: "undefined",
      description: "You've Successfully updated your LocomotiveCMS settings",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "settingssavesuccess",
      next: "editsubdomain",
      overlay: true,
      title: "Great Work!"
    });
  }
  
  
  /*
  *
  * Global 
  *
  */
  guiders.createGuider({
    attachTo: "#help",
    buttons: [{name: "Quit", onclick: guiders.hideAll}],
    description: "How To:<ul>\
    <li><a id='newpage' class='tutorial' href=\"/admin/pages#guider=newpage\">Make a new Page</a></li>\
    <li><a id='viewsite' class='tutorial' href=\"\">View Your Site</a></li>\
    <li><a id='pagewelcome' class='tutorial' href=\"\">Edit A Page</a></li>\
    <li><a id='modelwelcome' class='tutorial' href=\"\">Edit a a Content instance</a></li>\
    <li><a id='settingswelcome' class='tutorial' href=\"\">Edit your site's settings</a></li></ul>",
    id: "help",
    position: 6,
    width: 200,
    title: "Locomotive Guides",
  });
  
  $(".tutorial").click(function(){
    guiders.hideAll();
    guiders.show($(this).attr('id'));
    return false;
  });
  
  guiders.createGuider({
    attachTo: "#viewsite_ele",
    buttons: [{name: "Close", onclick: guiders.hideAll}],
    description: "This will take you to the 'frontend' of your site. Where you can see what users visiting your site see.",
    id: "viewsite",
    position: 6,
    width: 280,
    title: "Click Here To View Your Site",
  });
  
  guiders.createGuider({
    attachTo: "undefined",
    description: "You've gone through the LocomotiveCMS guide! For more info on LocomotiveCMS,\
    checkout out <a href='http://www.locomotivecms.com/support/'>The LocomotiveCMS support pages</a>",
    buttons: [{name: "Finished!", onclick: guiders.hideAll}],
    id: "congratulations",
    overlay: true,
    title: "Congratulations!"
  });
  
  
  
});