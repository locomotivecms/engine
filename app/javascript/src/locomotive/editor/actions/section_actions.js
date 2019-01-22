import { upperCase, debounce } from 'lodash';

// Services
import * as Preview from '../services/preview_service';
import { fetchSectionContent } from '../services/sections_service';

// Constants
const DEBOUNCE_DELAY = 300; // in milliseconds

// Helpers
const actionName = (name, section) => {
  return `${upperCase(section.source)}::${name}`;
}

// Update the content of a section (excluding adding/moving/removing blocks)
const _updateSectionInput = (section, blockId, fieldType, id, newValue) => {
  return {
    type: blockId ? actionName('SECTION::BLOCK::UPDATE_INPUT', section) : actionName('SECTION::UPDATE_INPUT', section),
    section,
    blockId,
    fieldType,
    id,
    newValue
  }
}

const reloadSectionHTML = (getState, section, blockId) => {
  const { editor: { api }, iframe: { _window }, content } = getState();

  // now, get the fresh content
  const sectionContent = fetchSectionContent(content, section);

  return api.loadSectionHTML(section, sectionContent)
  .then(html => {
    Preview.updateSection(_window, section, html);

    Preview.selectSection(_window, section, blockId);
  });
}

// FIXME: we don't want the section to be updated too frequently
const debouncedReloadSectionHTML = debounce(reloadSectionHTML, DEBOUNCE_DELAY);

export function updateSectionInput(section, blockId, fieldType, id, newValue) {
  return (dispatch, getState) => {
    const { editor: { api }, iframe: { _window } } = getState();

    // forward the action to the content reducer
    dispatch(_updateSectionInput(section, blockId, fieldType, id, newValue));

    if (fieldType === 'text')
      Preview.updateSectionText(_window, section, blockId, id, newValue)
      .catch(() => {
        // FIXME: the text wasn't wrapped directly in a HTML tag
        debouncedReloadSectionHTML(getState, section, blockId);
      })
    else {
      debouncedReloadSectionHTML(getState, section, blockId);
    }
  }
}

// Select a section or a block (ie: scroll up or down to the section or display a block)
const _selectSection = (section, blockId) => {
  return {
    type: 'SECTION::SELECT',
    section,
    blockId
  }
}

export function selectSection(section, blockId) {
  return (dispatch, getState) => {
    const { iframe: { _window } } = getState();
    Preview.selectSection(_window, section, blockId);
    dispatch(_selectSection(section));
  };
}

// Deselect a section (ie: just let the iframe knows about it)
const _deselectSection = (section, blockId) => {
  return {
    type: 'SECTION::DESELECT',
    section,
    blockId
  }
}

export function deselectSection(section, blockId) {
  return (dispatch, getState) => {
    const { iframe: { _window } } = getState();
    Preview.deselectSection(_window, section, blockId);
    dispatch(_deselectSection(section));
  };
}
