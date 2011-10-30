/* Brazilian Portuguese initialisation for the jQuery UI date picker plugin. */
/* Written by Raphael Costa (raphael@experia.com.br)  */
jQuery(function($){
	$.datepicker.regional['pt-BR'] = {
		closeText: 'Fechar',
		prevText: '&#x3c;Ant',
		nextText: 'Prox&#x3e;',
		currentText: 'Atual',
		monthNames: ['Janeiro','Fevereiro','Março','Abril','Maio','Junho',
		'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'],
		monthNamesShort: ['Jan','Fev','Mar','Abr','Mai','Jun',
		'Jul','Ago','Set','Out','Nov','Dez'],
		dayNames: ['Domingo','Segunda','Terça','Quarta','Quinta','Sexta','Sábado'],
		dayNamesShort: ['Dom','Seg','Ter','Qua','Qui','Sex','Sab'],
		dayNamesMin: ['Do','Se','Te','Qua','Qu','Se','Sa'],
		dateFormat: 'dd/mm/yy', firstDay: 1,
		isRTL: false};
});