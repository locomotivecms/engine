$(document).ready(function(){
  
  /*
  *
  * /admin/pages
  *
  */
  if(window.location.pathname == "/admin/pages"){
    
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
      attachTo: "#help_ele",
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
      description: "A page is a collection of content on your site that can be reached at a web address <br /></br> For this example we will edit the 'About Us' page. To do that you would click on the page name.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next", onclick: function(){
                  window.location = $('ul.folder:first li a').attr('href') + "#guider=editpagewelcome"
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
  
  }
  
  
  /*
  *
  * /admin/pages/edit 
  *
  */
  if(window.location.pathname.indexOf('edit') !== -1){
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
      description: "",
      id: "editpagetitle",
      next: "help",
      position: 6,
      width: 250,
      height: 100,
      title: "Click here to edit the page title"
    });
  
    guiders.createGuider({
      description: "A page is a collection of content on your site that can be reached by an address",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "pagetitle",
      next: "editpagecontent",
      title: "How to Change a Page Title"
    });
  
  }
  
  guiders.createGuider({
    attachTo: "#help_ele",
    buttons: [{name: "Quit", onclick: guiders.hideAll}],
    description: "How To:<ul>\
    <li><a id='newpage' class='tutorial' href=\"/admin/pages#guider=newpage\">Make a new Page</a></li>\
    <li><a id='viewsite' class='tutorial' href=\"\">View Your Site</a></li>\
    <li><a id='editpagetutorial' class='tutorial' href=\"\">Edit A Page</a></li>\
    <li><a id='editpagetutorial' class='tutorial' href=\"\">Create Content</a></li>\
    <li><a id='editpagetutorial' class='tutorial' href=\"\">Save Your Site</a></li>\
    <li><a id='editpagetutorial' class='tutorial' href=\"\">Edit a a Content instance</a></li>\
    <li><a id='editpagetutorial' class='tutorial' href=\"\">Edit your site's settings</a></li></ul>",
    id: "help",
    position: 6,
    width: 200,
    title: "Locomotive Tutorials",
  });
  
  $(".tutorial").click(function(){
    guiders.hideAll();
    guiders.show($(this).attr('id'));
    return false;
  });
  
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
    buttons: [{name: "Quit", onclick: guiders.hideAll}],
    description: "Click above to make a new page",
    id: "newpage",
    position: 6,
    width: 200,
    title: "Make a new page",
  });
  
  guiders.createGuider({
    attachTo: "#viewsite_ele",
    buttons: [{name: "Quit", onclick: guiders.hideAll}],
    description: "This will take you to the 'frontend' of your site. Where you can see what users visiting your site see.",
    id: "viewsite",
    position: 6,
    width: 250,
    title: "Click Here To View Your Site",
  });
  
  
  
  
});