import React from 'react';
import GlobalContext from '../context';
import { find } from 'lodash';

export default function withGlobalVars(Component) {

  // Helpers
  const findSectionDefinition = (sectionDefinitions, sectionType) => {
    return find(sectionDefinitions, def => def.type === sectionType)
  }

  const findBlockDefinition = (sectionDefinition, blockType) => {
    return find((sectionDefinition || {}).blocks, def => def.type === blockType);
  }

  return function WrappedComponent(props) {
    return (
      <GlobalContext.Consumer>
        {value =>
          <Component
            findSectionDefinition={findSectionDefinition.bind(null, value.sectionDefinitions)}
            findBlockDefinition={findBlockDefinition}
            {...value}
            {...props}
          />
        }
      </GlobalContext.Consumer>
    );
  };
}
