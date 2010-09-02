/*
* Aloha Editor
* Author & Copyright (c) 2010 Gentics Software GmbH
* aloha-sales@gentics.com
* Licensed unter the terms of http://www.aloha-editor.com/license.html
*/
if(typeof EXAMPLE=="undefined"||!EXAMPLE){var EXAMPLE={}}EXAMPLE.DummyDCPlugin=new GENTICS.Aloha.Plugin("com.example.aloha.DummyDC");EXAMPLE.DummyDCPlugin.languages=["en","de","eo","fi","fr","it"];EXAMPLE.DummyDCPlugin.init=function(){GENTICS.Aloha.FloatingMenu.addButton("GENTICS.Aloha.continuoustext",new GENTICS.Aloha.ui.Button({iconClass:"GENTICS_button GENTICS_button_addPerson",size:"small",tooltip:this.i18n("button.person.tooltip")}),GENTICS.Aloha.i18n(GENTICS.Aloha,"floatingmenu.tab.insert"),1);GENTICS.Aloha.FloatingMenu.addButton("GENTICS.Aloha.continuoustext",new GENTICS.Aloha.ui.Button({iconClass:"GENTICS_button GENTICS_button_addEvent",size:"small",tooltip:this.i18n("button.event.tooltip")}),GENTICS.Aloha.i18n(GENTICS.Aloha,"floatingmenu.tab.insert"),1)};