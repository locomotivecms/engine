// Helpers
const actionName = (name, sectionId) => {
  return `${sectionId ? '' : 'STATIC_'}${name}`;
}

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

export function previewSection(newSection) {
  return {
    type:         'SECTION::PREVIEW',
    newSection
  }
}

export function addSection(newSection) {
  return {
    type:         'SECTION::ADD',
    newSection
  }
}

export function moveSection(oldIndex, newIndex, sectionId, targetSectionId) {
  return {
    type:         'SECTION::MOVE',
    oldIndex,
    newIndex,
    sectionId,
    targetSectionId
  }
}

export function cancelAddSection() {
  return {
    type:         'SECTION::CANCEL_ADD'
  }
}

export function removeSection(sectionId) {
  return {
    type:         'SECTION::REMOVE',
    sectionId
  }
}

export function updateSectionInput(sectionType, sectionId, fieldType, id, newValue) {
  return {
    type:         actionName('SECTION::UPDATE_INPUT', sectionId),
    sectionType,
    sectionId,
    fieldType,
    id,
    newValue
  }
}

// SECTION BLOCKS


export function addSectionBlock(sectionType, sectionId, newBlock) {
  return {
    type:         actionName('SECTION::BLOCK::ADD', sectionId),
    sectionType,
    sectionId,
    newBlock
  }
}

export function moveSectionBlock(sectionType, sectionId, oldIndex, newIndex) {
  return {
    type:         actionName('SECTION::BLOCK::MOVE', sectionId),
    sectionType,
    sectionId,
    oldIndex,
    newIndex
  }
}

export function removeSectionBlock(sectionType, sectionId, blockId) {
  return {
    type:         actionName('SECTION::BLOCK::REMOVE', sectionId),
    sectionType,
    sectionId,
    blockId
  }
}

export function updateSectionBlockInput(sectionType, sectionId, blockId, fieldType, id, newValue) {
  return {
    type:         actionName('SECTION::BLOCK::UPDATE_INPUT', sectionId),
    sectionType,
    sectionId,
    blockId,
    fieldType,
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

export function onIframeOperationsDone() {
  return {
    type:         'IFRAME::DONE'
  }
}
