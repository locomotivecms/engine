import ApiFactory from '../services/api';
import { isBlank, waitUntil } from '../utils/misc';

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
    const { editor: { api, pageChanged, locale }, content: { site, page }, iframe: { _window } } = getState();

    return api.saveContent(site, page, locale)
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
      contentTypes:       data.contentTypes,
      changed:            false,
      pageChanged:        false,
      formErrors:         {},
      locale:             data.locale,
      locales:            data.locales,
      api:                ApiFactory(urls, data.locale),
      urls
    }
  }
}

const _reloadEditor = (dispatch, getState, pageId, contentEntryId, locale) => {
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
}

export function reloadEditor(pageId, contentEntryId, locale) {
  return (dispatch, getState) => {
    _reloadEditor(dispatch, getState, pageId, contentEntryId, locale);
  };
}

export function changeLocale(pageId, contentEntryId, locale) {
  return (dispatch, getState) => {
    dispatch(_startLoadingIframe(null));

    // just change the url of the iframe, the unload trigger of the iframe
    // will take care of the rest
    const { editor: { urls }, iframe: { _window } } = getState();

    _window.location.href = urls.localized_previews[locale];
  };
}

// PREVIEW / IFRAME

const _startLoadingIframe = contentWindow => {
  return {
    type:         'IFRAME::NEW_SOURCE',
    _window:      contentWindow
  }
}

export function startLoadingIframe(contentWindow) {
  return _startLoadingIframe(contentWindow);
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
