import ApiFactory from '../services/api';
import { waitUntil } from '../utils/misc';

// Services
import * as Preview from '../services/preview_service';

// Actions
export * from './page_actions';
export * from './section_actions';
export * from './section_block_actions';
export * from './dropzone_actions';

// GLOBAL

const _persistChanges = isSuccess => {
  return {
    type:     'PERSIST_CHANGES',
    success:  isSuccess
  }
}

const _persistPageChanges = (isSuccess, errors) => {
  return {
    type:     'PAGE::PERSIST_CHANGES',
    success:  isSuccess,
    errors
  }
}

export function persistChanges(result, data) {
  return (dispatch, getState) => {
    const { notify, i18n } = window.Locomotive;
    const { editor: { api, pageChanged }, content: { site, page }, iframe: { _window } } = getState();

    return api.saveContent(site, page)
    .then(data => {
      dispatch(_persistChanges(true))

      if (pageChanged) {
        Preview.reload(_window, data.previewPath);
        dispatch(_persistPageChanges(true));
      }

      return true;
    })
    .catch(errors => {
      dispatch(_persistChanges(false))

      if (pageChanged) {
        dispatch(_persistPageChanges(false, errors));
      }

      return false;
    });

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
      changed:            false,
      pageChanged:        false,
      formErrors:         {},
      api:                ApiFactory(urls),
      urls
    }
  }
}

export function reloadEditor(pageId, contentEntryId, locale) {
  return (dispatch, getState) => {
    const { editor: { api } } = getState();
    const now = new Date().getMilliseconds();

    // load the new data + wait a little bit to avoid a flickering
    api.loadContent(pageId, contentEntryId, locale)
    .then(response => waitUntil(now, null, () => {
      dispatch(loadEditor(response.data, response.urls));

      // little hack to get a smooth transition
      setTimeout(() => {
        dispatch({ type: 'IFRAME::LOADED', _window: getState().iframe._window });
      }, 300); // 300ms => delay of the page view animation
    }));
  };
}

// PREVIEW / IFRAME

export function startLoadingIframe(contentWindow) {
  return {
    type:         'IFRAME::NEW_SOURCE',
    _window:      contentWindow
  }
}

export function onIframeLoaded(contentWindow) {
  return {
    type:         'IFRAME::LOADED',
    _window:      contentWindow
  }
}

export function onIframeOperationsDone() {
  return {
    type:         'IFRAME::DONE'
  }
}
