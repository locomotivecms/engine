window.TinyMceDefaultSettings = {
  theme : 'advanced',
  skin : 'locomotive',
  plugins: 'safari,jqueryinlinepopups,locomotive_media,fullscreen',
  extended_valid_elements: 'iframe[width|height|frameborder|allowfullscreen|src|title]',
  theme_advanced_buttons1 : 'fullscreen,code,|,bold,italic,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,outdent,indent,blockquote,|,link,unlink,|,locomotive_media',
  theme_advanced_buttons2 : 'formatselect,fontselect,fontsizeselect',
  theme_advanced_buttons3 : '',
  theme_advanced_toolbar_location : "top",
  theme_advanced_toolbar_align : "left",
  height: '300',
  width: '709',
  inlinepopups_skin: 'locomotive',
  convert_urls: false,
  fullscreen_new_window : false,
  fullscreen_settings : {
    theme_advanced_path_location : "top"
  }
  /*
  *
  * These are call backs aide in the guider creation
  *
  */
  // onchange_callback: function(){
  //   if($('#pageeditcontent:visible').length > 0){
  //     guiders.next();
  //   }
  // }
  // ,
  // oninit: function(){
  //   if(typeof window.guiders !== 'undefined' &&
  //      window.location.pathname.match('admin/pages/.+\/edit') != null){
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
  //   }
  // }
};