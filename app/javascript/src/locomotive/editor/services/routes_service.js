import { compact } from 'lodash';

export const build = (pageId, contentEntryId, baseUrl) => {
  const _pageId       = compact([pageId, contentEntryId]).join('-');
  const basePath      = `/${_pageId}/content/edit`;
  const sectionsPath  = `${basePath}/sections`;

  const editPagePath  = (pageId, contentEntryId) => {
    const id = [pageId, contentEntryId].filter(n => n).join('-');
    return `${baseUrl}/${id}/content/edit`;
  } 

  const rootPath              = () => basePath;  
  const newSectionPath        = () => `${basePath}/sections/dropzone/new`;

  const sectionPath = (section) => {
    return `${sectionsPath}/${section.uuid}`;
  }
  const editSectionPath = (section) => {
    return `${sectionPath(section)}/edit`;
  }
  
  const blockPath = (section, blockType, blockId) => {
    return `${sectionPath(section)}/blocks/${blockType}/${blockId}`;
  }
  const editBlockPath = (section, blockType, blockId) => {
    return `${blockPath(section, blockType, blockId)}/edit`;
  }
  
  const blockParentPath = (section) => {
    return `${sectionPath(section)}/edit`;
  }

  const pickImagePath = (section, blockType, blockId, settingType, settingId) => {
    const postfix = `setting/${settingType}/${settingId}/images`;

    if (blockType && blockId)
      return `${blockPath(section, blockType, blockId)}/${postfix}`;
    else
      return `${sectionPath(section)}/${postfix}`;
  }

  const pickAssetPath = (section, blockType, blockId, settingType, settingId) => {
    const postfix = `setting/${settingType}/${settingId}/assets`;

    if (blockType && blockId)
      return `${blockPath(section, blockType, blockId)}/${postfix}`;
    else
      return `${sectionPath(section)}/${postfix}`;
  }

  const pickUrlPath = (section, blockType, blockId, settingType, settingId) => {
    const postfix = `setting/${settingType}/${settingId}/pick-url`;

    if (blockType && blockId)
      return `${blockPath(section, blockType, blockId)}/${postfix}`;
    else
      return `${sectionPath(section)}/${postfix}`;
  }

  const pickContentEntryPath = (section, blockType, blockId, settingType, settingId) => {
    const postfix = `setting/${settingType}/${settingId}/content-entry`;

    if (blockType && blockId)
      return `${blockPath(section, blockType, blockId)}/${postfix}`;
    else
      return `${sectionPath(section)}/${postfix}`;
  }

  return {
    rootPath,
    editPagePath,
    editSectionPath,
    newSectionPath,
    editBlockPath,
    blockParentPath,
    pickImagePath,
    pickAssetPath,
    pickUrlPath,
    pickContentEntryPath
  }
}