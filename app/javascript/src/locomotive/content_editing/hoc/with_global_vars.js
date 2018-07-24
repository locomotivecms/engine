import React from 'react';
import { compose } from 'redux';
// import GlobalContext from '../context';
import withRedux from './with_redux';
import { find } from 'lodash';

// Services
// import ApiFactory from '../services/api';

const withGlobalVars = Component => {

  // Helpers
  const findSectionDefinition = (sectionDefinitions, sectionType) => {
    return find(sectionDefinitions, def => def.type === sectionType)
  }

  const findBlockDefinition = (sectionDefinition, blockType) => {
    return find((sectionDefinition || {}).blocks, def => def.type === blockType);
  }

  return function WrappedComponent(props) {
    const hasSections = props.sections.all.length > 0 || props.sections.dropzone;
    const hasEditableElements = props.editableElements.length > 0;

    return (
      <Component
        findSectionDefinition={findSectionDefinition.bind(null, props.sectionDefinitions)}
        findBlockDefinition={findBlockDefinition}
        hasSections={hasSections}
        hasEditableElements={hasEditableElements}
        {...props}
      />
    );
  };
}

// TODO: splat

export default compose(
  withRedux(state => { return {
    pageId:             state.page.id,
    api:                state.editor.api,
    urls:               state.editor.urls,
    sections:           state.editor.sections,
    sectionDefinitions: state.editor.sectionDefinitions,
    editableElements:   state.editor.editableElements
  } }),
  withGlobalVars
);


// export default function withGlobalVars(Component) {

//   // Helpers
//   const findSectionDefinition = (sectionDefinitions, sectionType) => {
//     return find(sectionDefinitions, def => def.type === sectionType)
//   }

//   const findBlockDefinition = (sectionDefinition, blockType) => {
//     return find((sectionDefinition || {}).blocks, def => def.type === blockType);
//   }

//   return function WrappedComponent(props) {
//     return (
//       <GlobalContext.Consumer>
//         {value =>
//           <Component
//             findSectionDefinition={findSectionDefinition.bind(null, value.sectionDefinitions)}
//             findBlockDefinition={findBlockDefinition}
//             {...value}
//             {...props}
//           />
//         }
//       </GlobalContext.Consumer>
//     );
//   };
// }


