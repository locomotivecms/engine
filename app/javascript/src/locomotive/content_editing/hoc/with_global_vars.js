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
  const routes = {
    sectionsPath: () => '/sections',
    editStaticSectionPath: (sectionType) => `/sections/${sectionType}/edit`,
    editSectionPath: (sectionType, sectionId) => `/dropzone_sections/${sectionType}/${sectionId}/edit`,
    newSectionPath: () => '/dropzone_sections/pick',
    editBlockPath: (sectionType, sectionId, blockType, blockId) => {
      const prefix = sectionId ?
        `/dropzone_sections/${sectionType}/${sectionId}` :
        `/sections/${sectionType}`;
      return `${prefix}/blocks/${blockType}/${blockId}/edit`;
    },
    editableElementsPath: () => '/editable_elements'
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
