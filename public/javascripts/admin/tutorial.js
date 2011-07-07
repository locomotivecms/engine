$(document).ready(function(){
  
  guiders.createGuider({
    description: "Welcome to LocomotiveCMS, <br /><br /> This guide will help you get up and running with locomotive",
    buttons: [{name: "Quit Guide", onclick: guiders.hideAll},
              {name: "Continue", onclick: guiders.next}],
    id: "welcome",
    next: "help",
    overlay: true,
    title: "Welcome to Locomotive CMS"
  });

  guiders.createGuider({
    attachTo: "#tutorial",
    buttons: [{name: "Close", onclick: guiders.hideAll}],
    description: "How To:<ul>\
    <li><a id='new_page_tutorial' href=\"/admin/pages#guider=newpage\">Make a new Page</a></li>\
    <li><a href=\"\">Edit a Page</a></li></ul>",
    id: "help",
    position: 6,
    width: 200,
    title: "Locomotive Tutorials",
  });
  
  $('#new_page_tutorial').click(function(){
    guiders.hideAll();
    guiders.show('newpage');
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
  
  
});