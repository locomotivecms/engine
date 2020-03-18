import { find, findIndex, forEach, keyBy, mapValues } from 'lodash';
import { uuid, presence, stripHTML, isBlank } from '../utils/misc';

export function build(sectionDefinition, blockType, index) {
  const blockDefinition = find(sectionDefinition.blocks, def => def.type === blockType);
  const settings = mapValues(
    keyBy(blockDefinition.settings, setting => setting.id),
    setting => setting.default
  )

  return {
    id:   uuid(),
    type: blockType,
    index,
    settings
  }
}

export function findNextIndex(blocks) {
  var index = blocks ? blocks.length : 0;

  forEach(blocks, block => {
    if (block?.index && block.index > index)
      index = block.index;
  })

  return index + 1;
}

export function fetchBlockContent(sectionContent, blockId) {
  return blockId ? find(sectionContent.blocks, b => b.id === blockId) : null;
}

export function findBlockIndex(globalContent, section, blockId) {
  const content = globalContent[section.source].sectionsContent;
  const blocks  = content[section.key].blocks;
  return findIndex(blocks, block => block.id === blockId);
}

export function findDropzoneBlockIndex(section, blockId) {
  return findIndex(section.blocks, block => block.id === blockId);
}

const findFirstSettingValueOf = (type, blockContent, definition) => {
  if (isBlank(blockContent)) return null;

  // find the first <type> setting directly in the block
  const setting = find(definition.settings, setting => setting.type === type);

  return setting ? presence(blockContent.settings[setting.id]) : null;
}

export function findBetterText(blockContent, definition) {
  return stripHTML(findFirstSettingValueOf('text', blockContent, definition));
}

export function findBetterImageAndText(blockContent, definition) {
  const text  = findBetterText(blockContent, definition);
  var image   = findFirstSettingValueOf('image_picker', blockContent, definition);

  // use the cropped version?
  image = image && typeof(image) === 'object' ? image.cropped || image.source : image;

  return { image, text };
}
