/**
* wSlide 0.1 - http://www.webinventif.fr/wslide-plugin/
* 
* Rendez vos sites glissant !
*
* Copyright (c) 2008 Julien Chauvin (webinventif.fr)
* Licensed under the Creative Commons License:
* http://creativecommons.org/licenses/by/3.0/
*
* Date: 2008-01-27
*/
(function($){
	$.fn.wslide = function(h) {
		h = jQuery.extend({
			width: 150,
			height: 150,
			pos: 1,
			col: 1,
			effect: 'swing',
			fade: false,
			horiz: false,
			autolink: true,
			duration: 1500
			}, h);
		function gogogo(g){
			g.each(function(i){
				var a = $(this);
				var uniqid = a.attr('id');
				if(uniqid == undefined){
					uniqid = 'wslide'+i;
				}
				
				if ($(this).parent().hasClass('wslide-wrap'))
					a = $(this).parent();
				else {
					$(this).wrap('<div class="wslide-wrap" id="'+uniqid+'-wrap"></div>');
					a = $('#'+uniqid+'-wrap');
				}				
				
				var b = a.find('ul li');
				var effets = h.effect;
				if(jQuery.easing.easeInQuad == undefined && (effets!='swing' || effets!='normal')){
					effets = 'swing';
				}
				var typex = h.width;
				var typey = h.height;
				function resultante(prop){
					var tempcalc = prop;
					tempcalc = tempcalc.split('px');
					tempcalc = tempcalc[0];
					return Number(tempcalc);
				}
				var litypex = typex-(resultante(b.css('padding-left'))+resultante(b.css('padding-right')));
				var litypey = typey-(resultante(b.css('padding-top'))+resultante(b.css('padding-bottom')));
				var col = h.col;
				if(h.horiz){
					col =  Number(b.length+1);
				}
				var manip = '';
				var ligne = Math.ceil(Number(b.length)/col);
				a.css('overflow','hidden').css('position','relative').css('text-align','left').css('height',typey+'px').css('width',typex+'px').css('margin','0').css('padding','0');
				a.find('ul').css('position','absolute').css('margin','0').css('padding','0').css('width',Number((col+0)*typex)+'px').css('height',Number(ligne*typey)+'px');
				b.css('display','block').css('overflow','hidden').css('float','left').css('height',litypey+'px').css('width',litypex+'px');
				b.each(function (i) {
					var offset = a.offset();
					var thisoffset = $(this).offset();
					$(this).attr('id',uniqid+'-'+Number(i+1)).attr('rel', Number(thisoffset.left-offset.left)+':'+Number(thisoffset.top-offset.top));
					manip += ' <a href="#'+uniqid+'-'+Number(i+1)+'">'+Number(i+1)+'</a>';
				});

				if(typeof h.autolink == 'boolean'){
					if(h.autolink){
						a.after('<div class="wslide-menu" id="'+uniqid+'-menu">'+manip+'</div>');
					}
				}else if (typeof h.autolink == 'string'){
					if($('#'+h.autolink).length){
						$('#'+h.autolink).html(manip);
					}else{
						a.after('<div id="#'+h.autolink+'">'+manip+'</div>');
					}
				}
				var start = '#'+uniqid+'-';
				var stoccurent = "";
				$('a[href*="'+start+'"]').unbind('click').click(function () { 
					$('a[href*="'+stoccurent+'"]').removeClass("on");
					$(this).addClass("on");
					var tri = $(this).attr('href');
					tri=tri.split('#');
					tri='#'+tri[1];
					stoccurent = tri;
					var decal = $(tri).attr('rel');
					decal = decal.split(':');
					var decal2 = decal[1];
					decal2 = -decal2;
					decal = decal[0];
					decal = -decal;
					if(h.fade){
						a.find('ul').animate({ opacity: 0 }, h.duration/2, effets, function(){$(this).css('top',decal2+'px').css('left',decal+'px');$(this).animate({ opacity: 1 }, h.duration/2, effets)} );
					}else{
						a.find('ul').animate({ top: decal2+'px',left: decal+'px' }, h.duration, effets );
					}
					return false;
				});
				if(h.pos <= 0){
					h.pos = 1;
				}
				$('a[href$="'+start+h.pos+'"]').addClass("on");
				var tri = $('a[href*="'+start+'"]:eq('+Number(h.pos-1)+')').attr('href');
				tri=tri.split('#');
				tri='#'+tri[1];
				stoccurent = tri;
				var decal = $(tri).attr('rel');
				decal = decal.split(':');
				var decal2 = decal[1];
				decal2 = -decal2;
				decal = decal[0];
				decal = -decal;
				a.find('ul').css('top',decal2+'px').css('left',decal+'px');

			})
		}
		gogogo(this);
		return this;
	}
})(jQuery);