// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Função para exibir datas nas configurações
	$(function() {
		$( "#begin_period" ).datepicker({dateFormat: 'dd-mm-yy'});
	});
	$(function() {
		$( "#end_periods" ).datepicker({dateFormat: 'dd-mm-yy'});
	});
// Função para exibir datas no cadastro professor
	$(function() {
		$( "#dt_ingresso" ).datepicker({dateFormat: 'dd-mm-yy'});
	});
// Função para exibir datas nos titulos dos professores
	$(function() {
		$( "#dt_titulo" ).datepicker({dateFormat: 'dd-mm-yy'});
	});

// Função para exibir datas/hora nos Anuncios
	$(function() {
		$( "#starts_at" ).datetimepicker({dateFormat: 'dd-mm-yy'});
	});
	$(function() {
		$( "#ends_at" ).datetimepicker({dateFormat: 'dd-mm-yy'});
	});
