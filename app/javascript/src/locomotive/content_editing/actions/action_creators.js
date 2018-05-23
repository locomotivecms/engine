// GLOBAL

export function persistChanges(result, data) {
  console.log(result, data);
  return {
    type: 'PERSIST_CHANGES',
    success: result
  }
}

// SECTIONS

export function updateStaticSectionInput(sectionType, id, newValue) {
  return {
    type:         'SECTION::UPDATE_INPUT',
    static:       true,
    sectionType,
    id,
    newValue
  }
}

// PREVIEW / IFRAME

export function onIframeLoaded(contentWindow) {
  return {
    type:         'IFRAME::LOADED',
    window:       contentWindow
  }
}
