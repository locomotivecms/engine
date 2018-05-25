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
    type:         'STATIC_SECTION::BLOCK::ADD',
    sectionType,
    newBlock
  }
}

export function moveStaticSectionBlock(sectionType, oldIndex, newIndex) {
  return {
    type:         'STATIC_SECTION::BLOCK::MOVE',
    sectionType,
    oldIndex,
    newIndex
  }
}

export function removeStaticSectionBlock(sectionType, blockId) {
  return {
    type:         'STATIC_SECTION::BLOCK::REMOVE',
    sectionType,
    blockId
  }
}

export function updateStaticSectionBlockInput(sectionType, blockId, id, newValue) {
  return {
    type:         'STATIC_SECTION::BLOCK::UPDATE_INPUT',
    sectionType,
    blockId,
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
