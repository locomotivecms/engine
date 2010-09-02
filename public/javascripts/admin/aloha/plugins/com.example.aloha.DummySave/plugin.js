/*
* Aloha Editor
* Author & Copyright (c) 2010 Gentics Software GmbH
* aloha-sales@gentics.com
* Licensed unter the terms of http://www.aloha-editor.com/license.html
*/
if(typeof EXAMPLE=="undefined"||!EXAMPLE){var EXAMPLE={}}EXAMPLE.DummySavePlugin=new GENTICS.Aloha.Plugin("com.example.aloha.DummySave");EXAMPLE.DummySavePlugin.languages=["en","de","fi","fr","it"];EXAMPLE.DummySavePlugin.init=function(){var that=this;var saveButton=new GENTICS.Aloha.ui.Button({label:this.i18n("save"),onclick:function(){that.save()}});GENTICS.Aloha.Ribbon.addButton(saveButton)};EXAMPLE.DummySavePlugin.save=function(){var content="";jQuery.each(GENTICS.Aloha.editables,function(index,editable){content=content+"Editable ID: "+editable.getId()+"\nHTML code: "+editable.getContents()+"\n\n"});alert(this.i18n("saveMessage")+"\n\n"+content)};