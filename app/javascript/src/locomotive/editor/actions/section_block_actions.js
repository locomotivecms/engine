import { upperCase } from 'lodash';

// Services
import * as Preview from '../services/preview_service';
import { fetchSectionContent } from '../services/sections_service';

// Helpers
const actionName = (name, section) => {
  return `${upperCase(section.source)}::${name}`;
}

const refreshSection = (getState, section, blockId) => {
  const { editor: { api }, iframe: { _window }, content } = getState();
  const sectionContent = fetchSectionContent(content, section);

  return api.loadSectionHTML(section, sectionContent)
    .then(html => {
      Preview.updateSection(_window, section, html);
      Preview.selectSection(_window, section, blockId);
    });
}

// Add a new block to the list of blocks of a section
const _addSectionBlock = (section, newBlock) => {
  return {
    type:         actionName('SECTION::BLOCK::ADD', section),
    section,
    newBlock
  }
}

export function addSectionBlock(section, newBlock) {
  return (dispatch, getState) => {
    dispatch(_addSectionBlock(section, newBlock));

    refreshSection(getState, section, newBlock.id);
  }
}

// Remove a block from the list of blocks of a section
const _removeSectionBlock = (section, blockId) => {
  return {
    type: actionName('SECTION::BLOCK::REMOVE', section),
    section,
    blockId
  }
}

export function removeSectionBlock(section, blockId) {
  return (dispatch, getState) => {
    // forward the action to the content reducer
    dispatch(_removeSectionBlock(section, blockId));

    refreshSection(getState, section, blockId);
  }
}

// Drag&drop a block

const _moveSectionBlock = (section, sortedBlocks) => {
  return {
    type: actionName('SECTION::BLOCK::MOVE', section),
    section,
    sortedBlocks
  }
}

export function moveSectionBlock(section, sortedBlocks) {
  return (dispatch, getState) => {
    // forward the action to the content reducer
    dispatch(_moveSectionBlock(section, sortedBlocks));

    refreshSection(getState, section);
  }
}

