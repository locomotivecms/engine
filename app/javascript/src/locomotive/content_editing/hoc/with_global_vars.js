import React from 'react';
import GlobalContext from '../context';
import { find } from 'lodash';

export default function withGlobalVars(Component) {

  // Helpers
  const findSectionDefinition = (sectionDefinitions, sectionType) => {
    return find(sectionDefinitions, def => def.type === sectionType)
  }

  // Routes
  const routes = {
    sectionsPath: () => '/sections',
    editStaticSectionPath: (sectionType) => `/sections/${sectionType}/edit`,
    editSectionPath: (sectionType, sectionId) => `/dropzone_sections/${sectionType}/${sectionId}/edit`,
    newSectionPath: () => '/dropzone_sections/pick',
    editableElementsPath: () => '/editable_elements'
  }

  return function WrappedComponent(props) {
    return (
      <GlobalContext.Consumer>
        {value =>
          <Component
            findSectionDefinition={findSectionDefinition.bind(null, value.sectionDefinitions)}
            {...routes}
            {...value}
            {...props}
          />
        }
      </GlobalContext.Consumer>
    );
  };
}
