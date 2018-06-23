import React from 'react';

const state = {
  sections:             {},
  sectionDefinitions:   {},
  hasSections:          false,
  hasEditableElements:  false,
  urls:                 {}
};

export default React.createContext(state);
