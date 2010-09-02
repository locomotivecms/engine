/*
* Aloha Editor
* Author & Copyright (c) 2010 Gentics Software GmbH
* aloha-sales@gentics.com
* Licensed unter the terms of http://www.aloha-editor.com/license.html
*/
GENTICS.Aloha.Ressource=function(ressourcePrefix,basePath){this.prefix=ressourcePrefix;this.basePath=basePath?basePath:ressourcePrefix;GENTICS.Aloha.RessourceRegistry.register(this)};GENTICS.Aloha.Ressource.prototype.settings=null;GENTICS.Aloha.Ressource.prototype.init=function(){};GENTICS.Aloha.Ressource.prototype.query=function(attrs){return null};GENTICS.Aloha.Ressource.prototype.resolveRessource=function(obj){return null};