$(document).ready(function() {

  // automatic slug from collection name
  $('#asset_collection_name').keypress(function() {
    var input = $(this);
    var slug = $('#asset_collection_slug');

    if (!slug.hasClass('filled')) {
      setTimeout(function() {
        slug.val(input.val().replace(/\s/g, '_').toLowerCase());
      }, 50);
    }
  });

  $('#asset_collection_slug').keypress(function() { $(this).addClass('filled'); });

  // sortable assets

  var updateAssetsOrder = function() {
    var list = $('ul.assets.sortable');
    var ids = jQuery.map(list.sortable('toArray'), function(e) {
      return e.match(/asset-(\w+)/)[1];
    }).join(',');
    $('#asset_collection_assets_order').val(ids || '');
  }

  var setLastClassForAssets = function() {
    $('ul.assets li.last').removeClass('last');
    var i = parseInt($('ul.assets li.asset').size() / 6);
    while (i > 0) {
      $('ul.assets li.asset:eq(' + (i * 6 - 1) + ')').addClass('last');
      i--;
    }
  }

  $('ul.assets.sortable').sortable({
    items: 'li.asset',
    stop: function(event, ui) { updateAssetsOrder(); setLastClassForAssets(); }
  });

  $('ul.assets.sortable li div.actions a.remove').click(function(e) {
    if (confirm($(this).attr('data-confirm'))) {
      $(this).parents('li').remove();

      updateAssetsOrder();

      if ($('ul.assets li.asset').size() == 0) $('p.no-items').show();

      setLastClassForAssets();
    }
    e.preventDefault();
    e.stopPropagation();
  });

});
