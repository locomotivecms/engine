// Services
import * as Preview from '../services/preview_service';

// Preview a section
const _previewView = (newSection) => {
  return {
    type: 'DROPZONE::SECTION::PREVIEW',
    newSection
  }
}

export function previewSection(newSection) {
  return (dispatch, getState) => {
    const { editor: { api }, iframe: { _window, previousSection } } = getState();

    api.loadSectionHTML(newSection, newSection)
    .then(html => {
      Preview.previewSection(_window, html, newSection, previousSection);
      Preview.selectSection(_window, newSection);
      dispatch(_previewView(newSection));
    });
  }
}

// Cancel the preview of a section
const _cancelPreviewSection = () => {
  return {
    type: 'DROPZONE::SECTION::CANCEL_PREVIEW'
  }
}

export function cancelPreviewSection(newSection) {
  return (dispatch, getState) => {
    const { iframe: { _window, previousSection } } = getState();

    if (previousSection)
      Preview.removeSection(_window, previousSection);

    dispatch(_cancelPreviewSection());
  }
}


// Add the preview section
export function addSection(newSection) {
  return {
    type: 'DROPZONE::SECTION::ADD',
    newSection
  }
}

// Remove a section from the dropzone
const _removeSection = (section) => {
  return {
    type:         'DROPZONE::SECTION::REMOVE',
    section
  }
}

export function removeSection(section) {
  return (dispatch, getState) => {
    const { iframe: { _window } } = getState();

    Preview.removeSection(_window, section);

    dispatch(_removeSection(section));
  }
}

// Drag&drop a section in the sections dropzone
const _moveSection = (oldIndex, newIndex, section, targetSection) => {
  return {
    type:         'DROPZONE::SECTION::MOVE',
    oldIndex,
    newIndex,
    section,
    targetSection
  }
}

export function moveSection(oldIndex, newIndex, section, targetSection) {
  return (dispatch, getState) => {
    const { iframe: { _window } } = getState();
    const direction = newIndex > oldIndex ? 'after' : 'before';

    Preview.moveSection(_window, section, targetSection, direction);
    Preview.selectSection(_window, section);

    dispatch(_moveSection(oldIndex, newIndex, section, targetSection));
  }
}


