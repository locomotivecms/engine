import { forEach, find, sortBy, pick, cloneDeep } from 'lodash';
import { uuid } from '../utils/misc';

const setDefaultValuesTo = (settings, object) => {
  forEach(settings, setting => {
    if (object[setting.id] === undefined && setting.default !== undefined)
      object[setting.id] = setting.default;
  });
}

// Build an instance of a section (content) out of a preset
// This instance can be used directly by a reducer.
export function buildSection(definitions, sectionType, presetIndex) {
  const definition = find(definitions, definition => definition.type === sectionType)

  if (definition === undefined) return null;

  const preset = definition.presets[presetIndex];

  if (preset === undefined) return null;

  // grab the attributes of the preset
  var section = cloneDeep(pick(preset, ['settings', 'blocks']));

  // and also add other default attributes (if some of them are missing)
  section = {
    id:       uuid(),
    name:     preset.name,
    type:     sectionType,
    settings: {},
    blocks:   [],
    ...section
  }

  // make sure all the settings are correctly filled
  // in by defaut values for both settings and blocks (if present)
  setDefaultValuesTo(definition.settings, section.settings);

  forEach(section.blocks, block => {
    block['id']       = uuid();
    block['settings'] = block['settings'] || {};

    const _definition = find(definition.blocks, _block => _block.type === block.type);
    if (_definition === undefined) return;

    setDefaultValuesTo(_definition.settings, block.settings);
  });

  return section;
}

// Build the list of categories. Each category has many sections.
// Each section has one or more more presets. The presets of a section
// can belong to different categories.
export function buildCategories(definitions) {
  var categories = [], currentId = 0;

  forEach(definitions, definition => {
    forEach(definition.presets || [], (preset, index) => {
      var category = find(categories, ['name', preset.category]);

      // build a new category if it doesn't exist
      if (category === undefined) {
        category = { id: currentId++, name: preset.category, presets: [] };
        categories.push(category)
      }

      // add the section/preset
      category.presets.push({
        id:     index,
        name:   preset.name,
        type:   definition.type,
        preset: index
      })
    });
  });

  // Inside a category, sort presets alphanumerically
  forEach(categories, category => {
    category.presets = sortBy(category.presets, ['name'])
  });

  return sortBy(categories, ['name']);
}
