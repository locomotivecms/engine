import React from 'react';
import { compose } from 'redux';
import withRedux from './with_redux';
import { find } from 'lodash';

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

export default compose(
  withRedux(state => { return {
    pageId:             state.content.page.id,
    contentEntryId:     state.content.page.contentEntryId,
    api:                state.editor.api,
    urls:               state.editor.urls,
    sections:           state.editor.sections,
    sectionDefinitions: state.editor.sectionDefinitions,
    editableElements:   state.editor.editableElements,
    uiLocale:           state.editor.uiLocale
  } }),
  withGlobalVars
);
