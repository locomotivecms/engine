import update from '../utils/immutable_update';
import { findSectionIndex } from '../services/sections_service';
import { findBlockIndex, findDropzoneBlockIndex } from '../services/blocks_service';

function content(state = {}, action) {
  switch (action.type) {

    // EDITOR
    case 'EDITOR::LOAD':
      return update(state, {
        site: { $set: action.content.site },
        page: { $set: action.content.page }
      });

    // PAGE
    case 'PAGE::SETTING::UPDATE':
      return update(state, {
        page: {
          [action.name]: { $set: action.newValue }
        }
      });

    // SECTIONS DROPZONE

    case 'DROPZONE::SECTION::ADD':
      return update(state, {
        page: {
          sectionsDropzoneContent: { $push: [action.newSection] }
        }
      });

    case 'DROPZONE::SECTION::UPDATE_INPUT':
      return update(state, {
        page: {
          sectionsDropzoneContent: {
            [findSectionIndex(state.page.sectionsDropzoneContent, action.section)]: {
              settings: {
                [action.id]: { $set: action.newValue }
              }
            }
          }
        }
      });

    case 'DROPZONE::SECTION::REMOVE':
      return update(state, {
        page: {
          sectionsDropzoneContent: {
            $splice: [[findSectionIndex(state.page.sectionsDropzoneContent, action.section), 1]]
          }
        }
      });

    case 'DROPZONE::SECTION::MOVE':
      return update(state, {
        page: {
          sectionsDropzoneContent: {
            $arrayMove: {
              oldIndex: action.oldIndex,
              newIndex: action.newIndex
            }
          }
        }
      });

    // BLOCKS IN THE SECTIONS DROPZONE

    case 'DROPZONE::SECTION::BLOCK::UPDATE_INPUT': {
      const dropzoneContent   = state.page.sectionsDropzoneContent;
      const sectionIndex      = findSectionIndex(dropzoneContent, action.section);
      const blockIndex        = findDropzoneBlockIndex(dropzoneContent[sectionIndex], action.blockId)

      return update(state, {
        page: {
          sectionsDropzoneContent: {
            [sectionIndex]: {
              blocks: {
                [blockIndex]: {
                  settings: {
                    [action.id]: { $set: action.newValue }
                  }
                }
              }
            }
          }
        }
      });
    }

    case 'DROPZONE::SECTION::BLOCK::ADD':
      return update(state, {
        page: {
          sectionsDropzoneContent: {
            [findSectionIndex(state.page.sectionsDropzoneContent, action.section)]: {
              blocks: { $push: [action.newBlock] }
            }
          }
        }
      });

    case 'DROPZONE::SECTION::BLOCK::REMOVE': {
      const dropzoneContent   = state.page.sectionsDropzoneContent;
      const sectionIndex      = findSectionIndex(dropzoneContent, action.section);

      return update(state, {
        page: {
          sectionsDropzoneContent: {
            [sectionIndex]: {
              blocks: { $splice: [[findDropzoneBlockIndex(dropzoneContent[sectionIndex], action.blockId), 1]] }
            }
          }
        }
      });
    }

    case 'DROPZONE::SECTION::BLOCK::MOVE':
      return update(state, {
        page: {
          sectionsDropzoneContent: {
            [findSectionIndex(state.page.sectionsDropzoneContent, action.section)]: {
              blocks: {
                $set: action.sortedBlocks
              }
            }
          }
        }
      });

    // SECTIONS CONTENT (BOTH PAGE AND SITE)

    case 'SITE::SECTION::UPDATE_INPUT':
    case 'PAGE::SECTION::UPDATE_INPUT':
      return update(state, {
        [action.section.source]: {
          sectionsContent: {
            [action.section.key]: {
              settings: {
                [action.id]: { $set: action.newValue }
              }
            }
          }
        }
      });

    case 'SITE::SECTION::BLOCK::ADD':
    case 'PAGE::SECTION::BLOCK::ADD':
      return update(state, {
        [action.section.source]: {
          sectionsContent: {
            [action.section.key]: {
              blocks: { $push: [action.newBlock] }
            }
          }
        }
      });

    case 'SITE::SECTION::BLOCK::MOVE':
    case 'PAGE::SECTION::BLOCK::MOVE':
      return update(state, {
        [action.section.source]: {
          sectionsContent: {
            [action.section.key]: {
              blocks: {
                $set: action.sortedBlocks
              }
            }
          }
        }
      });

    case 'SITE::SECTION::BLOCK::REMOVE':
    case 'PAGE::SECTION::BLOCK::REMOVE':
      return update(state, {
        [action.section.source]: {
          sectionsContent: {
            [action.section.key]: {
              blocks: { $splice: [[findBlockIndex(state, action.section, action.blockId), 1]] }
            }
          }
        }
      });


    case 'SITE::SECTION::BLOCK::UPDATE_INPUT':
    case 'PAGE::SECTION::BLOCK::UPDATE_INPUT':
      return update(state, {
        [action.section.source]: {
          sectionsContent: {
            [action.section.key]: {
              blocks: {
                [findBlockIndex(state, action.section, action.blockId)]: {
                  settings: {
                    [action.id]: { $set: action.newValue }
                  }
                }
              }
            }
          }
        }
      });

    default:
      return state;
  }
}

export default content;
