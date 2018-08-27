import ApiFactory from '../services/api';
import { waitUntil } from '../utils/misc';

export * from './section_actions';
export * from './section_block_actions';
export * from './dropzone_actions';

// GLOBAL

export function persistChanges(result, data) {
  // TODO: call the api

  // const { i18n } = window.Locomotive;
  // if (result)
  //   Locomotive.notify(i18n.success, 'success')
  // else
  //   Locomotive.notify(i18n.fail, 'danger')

  return {
    type: 'PERSIST_CHANGES',
    success: null //result
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

export function reloadEditor(pageId, contentEntryId, locale) {
  return (dispatch, getState) => {
    const { editor: { api } } = getState();
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
