/*
* Aloha Editor
* Author & Copyright (c) 2010 Gentics Software GmbH
* aloha-sales@gentics.com
* Licensed unter the terms of http://www.aloha-editor.com/license.html
*/
GENTICS.Aloha.RessourceRegistry=function(){this.ressources=new Array()};GENTICS.Aloha.RessourceRegistry.prototype.register=function(ressource){if(ressource instanceof GENTICS.Aloha.Ressource){this.ressources.push(ressource)}};GENTICS.Aloha.RessourceRegistry.prototype.init=function(){for(var i=0;i<this.ressources.length;i++){var ressource=this.ressources[i];if(GENTICS.Aloha.settings.ressources==undefined){GENTICS.Aloha.settings.ressources={}}ressource.settings=GENTICS.Aloha.settings.ressources[ressource.prefix];if(ressource.settings==undefined){ressource.settings={}}if(ressource.settings.enabled==undefined){ressource.settings.enabled=true}if(ressource.settings.enabled==true){this.ressources[i].init()}}};GENTICS.Aloha.RessourceRegistry.toString=function(){return"com.gentics.aloha.RessourceRegistry"};GENTICS.Aloha.RessourceRegistry=new GENTICS.Aloha.RessourceRegistry();GENTICS.Aloha.Ressources={};