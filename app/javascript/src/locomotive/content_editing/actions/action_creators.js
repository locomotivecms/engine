import ApiFactory from '../services/api';
import { waitUntil } from '../utils/misc';

export * from './section_actions';
export * from './section_block_actions';
export * from './dropzone_actions';

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
    content: {
      site: data.site,
      page: data.page
    },
    editor: {
      sections:           data.sections,
      sectionDefinitions: data.sectionDefinitions,
      editableElements:   data.editableElements,
      api:                ApiFactory(urls),
      urls
    }
  }
}

export function reloadEditor(api, pageId, contentEntryId, locale) {
  return dispatch => {
    const now = new Date().getMilliseconds();

    // Display the startup screen
    dispatch({ type: 'IFRAME::NEW_SOURCE' });

    // load the new data + wait a little bit to avoid a flickering
    api.loadContent(pageId, contentEntryId, locale)
    .then(response => waitUntil(now, null, () => {
      dispatch(loadEditor(response.data, response.urls));
    }));
  };
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

// SECTION (COMMON TO PAGE, SITE AND DROPZONE)

// export function updateSectionInput(section, fieldType, id, newValue) {
//   return {
//     type:         actionName('SECTION::UPDATE_INPUT', section),
//     section,
//     fieldType,
//     id,
//     newValue
//   }
// }

// export function selectSection(section) {
//   return {
//     type:         'SECTION::SELECT',
//     section
//   }
// }

// export function deselectSection(section) {
//   return {
//     type:         'SECTION::DESELECT',
//     section
//   }
// }

// SECTION BLOCKS

// export function updateSectionBlockInput(section, blockId, fieldType, id, newValue) {
//   return {
//     type:         actionName('SECTION::BLOCK::UPDATE_INPUT', section),
//     section,
//     blockId,
//     fieldType,
//     id,
//     newValue
//   }
// }

// export function addSectionBlock(section, newBlock) {
//   return {
//     type:         actionName('SECTION::BLOCK::ADD', section),
//     section,
//     newBlock
//   }
// }

// export function moveSectionBlock(section, oldIndex, newIndex) {
//   return {
//     type:         actionName('SECTION::BLOCK::MOVE', section),
//     section,
//     oldIndex,
//     newIndex
//   }
// }

// export function removeSectionBlock(section, blockId) {
//   return {
//     type:         actionName('SECTION::BLOCK::REMOVE', section),
//     section,
//     blockId
//   }
// }

// // TODO
// export function selectSectionBlock(section, blockType, blockId) {
//   return {
//     type:         'SECTION::BLOCK::SELECT',
//     section,
//     blockType,
//     blockId
//   }
// }

// // TODO
// export function deselectSectionBlock(section, blockType, blockId) {
//   return {
//     type:         'SECTION::BLOCK::DESELECT',
//     section,
//     blockType,
//     blockId
//   }
// }
