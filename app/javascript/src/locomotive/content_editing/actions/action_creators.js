// GLOBAL

export function persistChanges(result, data) {
  const { i18n } = window.Locomotive;
  if (result)
    Locomotive.notify(i18n.success, 'success')
  else
    Locomotive.notify(i18n.fail, 'danger')

  return {
    type: 'PERSIST_CHANGES',
    success: result
  }
}

// SECTIONS

export function updateStaticSectionInput(sectionType, id, newValue) {
  return {
    type:         'STATIC_SECTION::UPDATE_INPUT',
    sectionType,
    id,
    newValue
  }
}

// SECTION BLOCKS

export function addStaticSectionBlock(sectionType, newBlock) {
  return {
    type:         'STATIC_SECTION::ADD_BLOCK',
    sectionType,
    newBlock
  }
}

export function removeStaticSectionBlock(sectionType, blockId) {
  return {
    type:         'STATIC_SECTION::REMOVE_BLOCK',
    sectionType,
    blockId
  }
}

// PREVIEW / IFRAME

export function onIframeLoaded(contentWindow) {
  return {
    type:         'IFRAME::LOADED',
    window:       contentWindow
  }
}
