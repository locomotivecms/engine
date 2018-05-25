import { find, keyBy, mapValues } from 'lodash';
import { uuid } from '../utils/misc';

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
