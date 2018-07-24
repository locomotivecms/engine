import ApiFactory from '../services/api';
import { waitUntil } from '../utils/misc';


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

function loadEditor(data, urls) {
  return {
    type: 'EDITOR::LOAD',
    site: data.site,
    page: data.page,
    editor: {
      sections:           data.sections,
      sectionDefinitions: data.sectionDefinitions,
      editableElements:   data.editableElements,
      api:                ApiFactory(urls),
      urls
    }
  }
}

export function reloadEditor(api, pageId, locale) {
  return dispatch => {
    const now = new Date().getMilliseconds();

    // Display the startup screen
    dispatch({ type: 'IFRAME::NEW_SOURCE' });

    // load the new data + wait a little bit to avoid a flickering
    api.loadContent(pageId, locale)
    .then(response => waitUntil(now, null, () => {
      dispatch(loadEditor(response.data, response.urls));
    }));
  };
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

export function selectSection(sectionType, sectionId) {
  return {
    type:         'SECTION::SELECT',
    sectionType,
    sectionId
  }
}

export function deselectSection(sectionType, sectionId) {
  return {
    type:         'SECTION::DESELECT',
    sectionType,
    sectionId
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

export function cancelPreviewSection() {
  return {
    type:         'SECTION::CANCEL_PREVIEW'
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

export function selectSectionBlock(sectionType, sectionId, blockType, blockId) {
  return {
    type:         'SECTION::BLOCK::SELECT',
    sectionType,
    sectionId,
    blockType,
    blockId
  }
}

export function deselectSectionBlock(sectionType, sectionId, blockId) {
  return {
    type:         'SECTION::BLOCK::DESELECT',
    sectionType,
    sectionId,
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

export function onIframeOperationsDone() {
  return {
    type:         'IFRAME::DONE'
  }
}
