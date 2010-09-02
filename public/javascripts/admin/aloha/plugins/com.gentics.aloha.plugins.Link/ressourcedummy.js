/*
* Aloha Editor
* Author & Copyright (c) 2010 Gentics Software GmbH
* aloha-sales@gentics.com
* Licensed unter the terms of http://www.aloha-editor.com/license.html
*/
GENTICS.Aloha.Ressources.Dummy=new GENTICS.Aloha.Ressource("com.gentics.aloha.resources.Dummy");GENTICS.Aloha.Ressources.Dummy.init=function(){var data=[{id:1,text:"Link A",url:"/page1"},{id:2,text:"Link B",url:"/page2"},{id:3,text:"Link C",url:"/page3"},{id:4,text:"Link D",url:"/page4"}]};GENTICS.Aloha.Ressources.Dummy.query=function(attrs){return this.data};GENTICS.Aloha.Ressources.Dummy.resolve=function(obj){return null};