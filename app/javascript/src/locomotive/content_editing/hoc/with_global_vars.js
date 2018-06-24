import React from 'react';
import GlobalContext from '../context';
import { find } from 'lodash';

export default function withGlobalVars(Component) {

  // Helpers
  const findSectionDefinition = (sectionDefinitions, sectionType) => {
    return find(sectionDefinitions, def => def.type === sectionType)
  }

  const findBlockDefinition = (sectionDefinition, blockType) => {
    return find(sectionDefinition.blocks, def => def.type === blockType);
  }

  // Routes
  const editableElementsPath  = () => '/editable_elements';
  const sectionsPath          = () => '/sections';
  const newSectionPath        = () => '/dropzone_sections/pick';

  const staticSectionPath = sectionType => `/sections/${sectionType}`;
  const editStaticSectionPath = sectionType => {
    return `${staticSectionPath(sectionType)}/edit`;
  }

  const sectionPath = (sectionType, sectionId) => {
    return `/dropzone_sections/${sectionType}/${sectionId}`;
  }
  const editSectionPath = (sectionType, sectionId) => {
    return `${sectionPath(sectionType, sectionId)}/edit`;
  }

  const genericSectionPath = (sectionType, sectionId) => {
    return sectionId ? sectionPath(sectionType, sectionId) : staticSectionPath(sectionType);
  }

  const editBlockPath = (sectionType, sectionId, blockType, blockId) => {
    return `${genericSectionPath(sectionType, sectionId)}/blocks/${blockType}/${blockId}/edit`;
  }

  const blockParentPath = (sectionType, sectionId) => {
    return `${genericSectionPath(sectionType, sectionId)}/edit`;
  }

  const routes = {
    editableElementsPath,
    sectionsPath,
    editStaticSectionPath,
    editSectionPath,
    newSectionPath,
    editBlockPath,
    blockParentPath
  }

  return function WrappedComponent(props) {
    return (
      <GlobalContext.Consumer>
        {value =>
          <Component
            findSectionDefinition={findSectionDefinition.bind(null, value.sectionDefinitions)}
            findBlockDefinition={findBlockDefinition}
            {...routes}
            {...value}
            {...props}
          />
        }
      </GlobalContext.Consumer>
    );
  };
}
