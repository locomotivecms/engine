import { forEach, find, findIndex, sortBy, pick, cloneDeep } from 'lodash';
import { uuid, shortUuid, presence, isBlank, stripHTML } from '../utils/misc';

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
    id:         uuid(),
    name:       preset.name,
    type:       sectionType,
    anchor:     `${sectionType}-${shortUuid()}`,
    settings:   {},
    blocks:     [],
    ...section
  }

  // add attributes for the Editor tool
  section.uuid    = section.id;
  section.source  = 'dropzone';

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

export function fetchSectionContent(globalContent, section) {
  const { site, page } = globalContent;

  switch (section.source) {
    case 'site':
      return site.sectionsContent[section.key];
    case 'page':
      return page.sectionsContent[section.key];
    case 'dropzone':
      return find(page.sectionsDropzoneContent, s => s.id === section.id)
  }

  return null;
}

export function findSectionIndex(sections, section) {
  return findIndex(sections, _section => _section.id === section.id);
}

const findFirstSettingValueOf = (type, sectionContent, definition) => {
  var value = null;

  // find the first <type> setting directly in the section
  const setting = find(definition.settings, setting => setting.type === type);

  if (setting) {
    value = presence(sectionContent.settings[setting.id]);
  } else if (!isBlank(sectionContent.blocks)) {
    // no problem, try to find it in the blocks
    forEach(sectionContent.blocks, block => {
      if (!isBlank(value)) return; // already found

      // find the block definition
      const _definition = find(definition.blocks, _block => _block.type === block.type);
      const _setting    = find(_definition.settings || [], setting => setting.type === type);

      if (_setting)
        value = presence(block.settings[_setting.id]);
    });
  }

  return value;
}

export function findBetterImageAndText(sectionContent, definition) {
  var image = null, text = null;

  if (!definition.keep_icon) {
    image = findFirstSettingValueOf('image_picker', sectionContent, definition);
    image = image && typeof(image) === 'object' ? image.cropped || image.source : image;
  }

  if (!definition.keep_name)
    text = stripHTML(findFirstSettingValueOf('text', sectionContent, definition));

  return { image, text };
}

export function findBetterText(sectionContent, definition) {
  return definition.keep_name ? null : stripHTML(findFirstSettingValueOf('text', sectionContent, definition));
}

export function isEditable(definition) {
  return !(isBlank(definition.settings) && isBlank(definition.blocks));
}
