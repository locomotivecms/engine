export function buildProps(specificPropsHash) {
  const props = {
    site: undefined,
    page: undefined,
    editableElements: [],
    sections: {
      "all": [],
      "top": undefined,
      "bottom": undefined,
      "dropzone": undefined
    },
    sectionDefinitions: undefined,
    iframe: {
      loaded:     false,
      window:     null
    }
  };

  return { ...props, ...specificPropsHash };
}

