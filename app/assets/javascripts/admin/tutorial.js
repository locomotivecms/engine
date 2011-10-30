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

    var pagehook = (function(){
      var possibles = ['ul.folder:first li',
                       'ul#pages-list li'];
      for(var i = 0; i<possibles.length; i++){
        if($(possibles[i]).length > 0){
          return possibles[i];
        }
      }
    }());

    guiders.createGuider({
      attachTo: pagehook,
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next - Edit "+$(pagehook+' a:first').text()+"", onclick: function(){
                  window.location = $(pagehook+' a:first').attr('href') + "#guider=editpagewelcome"
                }
              }],
      description: "These are pages. You can click on the page name to edit it.",
      id: "pagepointer",
      next: "editpagewelcome",
      width: 200,
      position: 9,
      overlay: true,
      title: ""
    });

     guiders.createGuider({
       attachTo: "undefined",
       description: "A page is a collection of content on your site that can be reached at a web address <br /></br>\
       For this example we will edit the '"+$(pagehook+' a:first').text()+"' page. To do that you would click on the page name.",
       buttons: [{name: "Quit", onclick: guiders.hideAll},
                 {name: "Next"}],
       id: "pagewelcome",
       next: "pagepointer",
       overlay: true,
       title: "What is a page?"// ,
       //       onShow: function(){
       //         guiders.show('pagepointer')
       //       }
     });

     guiders.createGuider({
         attachTo: (function(){
           if($('li.hoverable:eq(2)').length > 0){
             return 'li.hoverable:eq(2)';
           }else{
             return 'li.hoverable:first';
           }
         }()),
         buttons: [{name: "Quit", onclick: guiders.hideAll},
                   {name: "Next - Edit an Event",
                               onclick: function(){
                                window.location = $('li.hoverable:eq(2) li:first a').attr('href') + "#guider=editmodelwelcome";
                               }}],
         description: "These are models.<br /> You can hover over to edit them. For this next section of the guide. We will edit an Event model. '"+$('.inner:eq(3) li:first a').text()+"' ",
         id: "modelpointer",
         next: "editpagewelcome",
         width: 240,
         position: 4,
         title: ""
       });

     guiders.createGuider({
       attachTo: 'div.action span',
       buttons: [],
       description: "Click here to make a new model",
       id: "newmodelpointer",
       next: "editpagewelcome",
       position: 6,
       overlay: true,
       width: 200,
       title: ""
     });

     guiders.createGuider({
       attachTo: 'div.action span',
       buttons: [],
       description: "Click here to make a new model",
       id: "newmodelpointer-next",
       next: "editpagewelcome",
       position: 6,
       width: 200,
       title: "",
       onShow: function(){
         // console.log("updating new model url");
         $('div.action a').attr('href',
         $('div.action a').attr('href') + "#guider=newmodelwelcome");
       }
     });


     guiders.createGuider({
       attachTo: "undefined",
       description: (function(){
         var ret = "What is a model?<br />\
         The concept of a model within locomotiveCMS is a peice of content that you might reuse through out your site.\
         Some example models could be: Blog posts, Products, Events, Locations, Photos<br /></br />"

         if($('li.hoverable').length > 1){
           ret += "For this next section of the guide. We will edit our Event model. '"+$('.inner:eq(3) li:first a').text()+"' ";
         }else{
           ret += "For this next section of the guide, lets make a new model";
         }

         return ret;
       }()),
       buttons: [{name: "Quit", onclick: guiders.hideAll},
                 {name: "Next"}],
                 // (function(){
                 //                   if($('li.hoverable').length < 1){
                 //                     return {
                 //                       name: "Next - Create a Model",
                 //                       onclick: function(){
                 //                         guiders.hideAll();
                 //                         guiders.show('newmodelpointer-next');
                 //                       }
                 //                     };
                 //                   }else{
                 //                     return  {
                 //                       name: "Next - Edit an Event",
                 //                       onclick: function(){
                 //                        window.location = $('li.hoverable:eq(2) li:first a').attr('href') + "#guider=editmodelwelcome";
                 //                       }
                 //                     };
                 //                   }
                 //                 }())],
       id: "modelwelcome",
       next: (function(){
         if($('li.hoverable').length > 1){
           return "modelpointer";
         }
           return 'newmodelpointer';
       }()),
       overlay: true,
       title: "Lets talk about Models...",
       // onShow: function(){
       //   if($('li.hoverable').length > 1){
       //     guiders.show("modelpointer");
       //   }
       //   //guiders.show('newmodelpointer');
       // }
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

    // /*
    // * We have to delay the creation of this guider
    // * so TinyMCE can render it
    // */
    // window.onload = function(){
    //   window.setTimeout(function(){
    //     guiders.createGuider({
    //       attachTo: '#page_editable_elements_attributes_1_content_ifr',
    //       title: "Edit the content of the page",
    //       description: "You can edit the content of your page in this text box. Go Ahead, add somethign like 'locomotiveCMS rocks!'. We'll wait for you.",
    //       buttons: [],
    //       id: "pageeditcontent",
    //       next: "savepageedit",
    //       position: 9,
    //       width: 300
    //     });
    //   }, 2000);
    // };

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


    var page_title = 'Guide Demo Page';

    guiders.createGuider({
      attachTo: "a.editable:first",
      buttons: [],
      title: "",
      id: "editpagetitle",
      next: "greatjob",
      position: 6,
      width: 200,
      height: 100,
      description: "Click here to edit the page title. <br /><br /> Change the title to '"+page_title+"'"
    });

    guiders.createGuider({
      attachTo: "undefined",
      description:     "You just changed the title of this page. Lets continue by editing the page content.",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next"}],
      id: "greatjob",
      next: "pageeditcontent",
      overlay: true,
      title: "Great Job!"
    });

    guiders.createGuider({
      buttons: [],
      attachTo: "button.light:last",
      description: "Click this save button to save any changes you've made to the page.",
      id: "savepageedit",
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

    function viewSiteClick(e){
      // console.log("viewsite click!");
      var $this = $(e.target);
      e.preventDefault();
      window.open($this.attr('href'),"_blank");
      $this.attr('href', '#');
      guiders.next();
      $this.unbind('click', viewSiteClick);
      return false;
      //should probably unbind this to prevent double clicking
    }

    guiders.createGuider({
      attachTo: "#viewsite",
      buttons: [],
      description: "This will open a new tab in your browser and take you to the 'frontend' of your site. The frontend is what other visitors to your site will see. Come back to this tab in your browser to continue the guide.",
      id: "viewsite2",
      next: "editfinish",
      position: 6,
      width: 280,
      title: "Click Here To View Your Site",
      onShow: function(){
        // console.log("binding click for view site", $('#viewsite'));
        $('#viewsite').bind('click', viewSiteClick);
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
  * New model
  *
  */
  if(window.location.pathname.match('admin/content_types/new') != null ||
     window.location.pathname.match('admin/content_types/.+/edit')){

      guiders.createGuider({
        attachTo: "undefined",
        description: "A model is how you define the content on your site. Lots of sites have: Blog Posts, Products, Photo Albums, Events.\
        These are all differnt models.<br /><br />\
        Models have fields. Fields are properties of a model. For example a Blog Post, has fields of: Author, Title, Content.<br /></br/>\
        Try creating your own model and saving it!",
        buttons: [{name: "Quit", onclick: guiders.hideAll},
                  {name: "Next"}],
        id: "newmodelwelcome",
        next: "createmodel",
        overlay: true,
        title: "Lets create a new model!"
      });

      guiders.createGuider({
        buttons: [],
        attachTo: "button.light:first",
        description: "Click this button to create your new model!",
        id: "createmodel",
        next: "help",
        position: 9,
        title: "Save Your Work",
        onShow: function(){
          $('#new_content_type').attr('action',
          $('#new_content_type').attr('action')+"#guider=newmodelsuccess");
        }
      });

      guiders.createGuider({
        attachTo: "undefined",
        description: (function(){
          if($('.inline-errors').length > 0){
              return "Looks like you forgot something. Please Check out the errors and try again!";
            }else{
              return "You've Successfully created a model! Moving on. Lets adjust the settings of your LocomotiveCMS";
            }
        }),
        buttons: [{name: "Quit", onclick: guiders.hideAll},
                  {name: "Next - Settings", onclick: function(){
                    window.location = "/admin/pages#guider=settingswelcome";
                  }}],
        id: "newmodelsuccess",
        next: "editsubdomain",
        overlay: true,
        title: (function(){
          if($('.inline-errors').length > 0){
              return "Uh oh.";
            }else{
              return "Great Work! You Made A New Model.";
            }
        }),
        onShow: (function(){
          if($('.inline-errors').length > 0){
              guiders.show('createmodel');
            }
        })
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
      next: (function(){
        if($('#site_subdomain').length > 0){
          return "editsubdomain";
        }else{
          return "settingssave";
        }
      }()),
      overlay: true,
      title: "The Settings Page"
    });

    if($('#site_subdomain').length > 0){
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
    }

    guiders.createGuider({
      buttons: [],
      attachTo: "button.light:last",
      description: "Click this update button to save any changes you've made to the settings.",
      id: "settingssave",
      position: 12,
      title: "Save Your Work",
      onShow: function(){
        $('form.save-with-shortcut').attr('action',
        $('form.save-with-shortcut').attr('action')+"#guider=settingssavesuccess");
      }
    });

    guiders.createGuider({
      attachTo: "undefined",
      title: "Great Work!",
      description: "You've Successfully updated your LocomotiveCMS settings. Dosen't that feel awesome?",
      buttons: [{name: "Quit", onclick: guiders.hideAll},
                {name: "Next", onclick: function(){
                  if($('#bushi_banner').length > 0){
                    guiders.hideAll();
                    guiders.show("bushi_banner_guide");
                  }else{
                    guiders.hideAll();
                    guiders.show("congratulations");
                  }
                }}],
      id: "settingssavesuccess",
       overlay: true
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
    <li><a id='newpage' class='tutorial' href=\"/admin/pages\">Make a new Page</a></li>\
    <li><a id='viewsite' class='tutorial' href=\"#\">View Your Site</a></li>\
    <li><a id='pagewelcome' class='tutorial' href=\"/admin/pages\">Edit A Page</a></li>\
    <li><a id='modelwelcome' class='tutorial' href=\"/admin/pages\">Edit a a Content instance</a></li>\
    <li><a id='settingseditwelcome' class='tutorial' href=\"/admin/current_site/edit\">Edit your site's settings</a></li></ul>",
    id: "help",
    position: 6,
    width: 200,
    title: "Locomotive Guides",
  });

  $(".tutorial").click(function(){
    var $this = $(this);
    guiders.hideAll();
    if($this.attr('href') != '#' && window.location.pathname != $this.attr('href')){
      window.location = $this.attr('href') + "#guider=" + $this.attr('id');
      window.location.reload();
    }else{
      guiders.show($this.attr('id'));
    }
    return false;
  });

  guiders.createGuider({
    attachTo: "#viewsite",
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
    buttons:[{name: "Finished!", onclick: guiders.hideAll}],
    id: "congratulations",
    next: "bushi_banner",
    overlay: true,
    title: "Congratulations!"
  });

  window.onload = function(){
    window.setTimeout(function(){
      if($('#bushi_banner').length > 0){
        guiders.createGuider({
          attachTo: "#bushi_banner",
          description: "You may have noticed the bar at the top of your site. Its provided by Bushido. Bushido are friends of LocomotiveCMS. They are our official hosting partner.\
          <br /><br /> They will keep your LocomotiveCMS site up and running. If you want to keep your LocomotiveCMS site, they have a short signup processes above. Check it out!",
          buttons: [{name: "Next"}],
          id: "bushi_banner_guide",
          overlay: true,
          title: "One more Thing...",
          next: "congratulations",
          position: 6
        });
      }
    }, 1000);
  };

});