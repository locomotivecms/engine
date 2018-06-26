import { find, keyBy, mapValues } from 'lodash';
import { uuid } from '../utils/misc';
import striptags from 'striptags';

export function build(sectionDefinition, blockType) {
  const blockDefinition = find(sectionDefinition.blocks, def => def.type === blockType);
  const settings = mapValues(
    keyBy(blockDefinition.settings, setting => setting.id),
    setting => setting.default
  )

  return {
    id:   uuid(),
    type: blockType,
    settings
  }
}

export function getLabelElements(blockDefinition, block) {
  const { name, settings } = blockDefinition;
  var elements = { name, image: null };

  // use the image if the first setting is an image picker
  if (settings[0] && settings[0].type === 'image_picker')
    elements.image = block.settings[settings[0].id];

  // go get the first text setting
  const setting = find(settings, setting => setting.type === 'text')

  if (setting)
    elements.name = striptags(block.settings[setting.id]);

  return elements;
}
