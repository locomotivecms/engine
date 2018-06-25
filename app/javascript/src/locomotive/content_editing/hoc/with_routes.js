import React from 'react';

export default function withRoutes(Component) {

  const editableElementsPath  = () => '/editable_elements';
  const sectionsPath          = () => '/sections';
  const newSectionPath        = () => '/dropzone_sections/pick';

  const staticSectionPath = sectionType => `/sections/${sectionType}`;
  const dropzoneSectionPath = (sectionType, sectionId) => {
    return `/dropzone_sections/${sectionType}/${sectionId}`;
  }

  const sectionPath = (sectionType, sectionId) => {
    return sectionId ? dropzoneSectionPath(sectionType, sectionId) : staticSectionPath(sectionType);
  }
  const editSectionPath = (sectionType, sectionId) => {
    return `${sectionPath(sectionType, sectionId)}/edit`;
  }

  const blockPath = (sectionType, sectionId, blockType, blockId) => {
    return `${sectionPath(sectionType, sectionId)}/blocks/${blockType}/${blockId}`;
  }
  const editBlockPath = (sectionType, sectionId, blockType, blockId) => {
    return `${blockPath(sectionType, sectionId, blockType, blockId)}/edit`;
  }

  const blockParentPath = (sectionType, sectionId) => {
    return `${sectionPath(sectionType, sectionId)}/edit`;
  }

  const imagesBlockPath = (sectionType, sectionId, blockType, blockId, settingType, settingId) => {
    return `${blockPath(sectionType, sectionId, blockType, blockId)}/setting/${settingType}/${settingId}/images`;
  }

  const routes = {
    editableElementsPath,
    sectionsPath,
    editSectionPath,
    newSectionPath,
    editBlockPath,
    blockParentPath,
    imagesBlockPath
  }

  return function WrappedComponent(props) {
    return (
      <Component
        {...routes}
        {...props}
      />
    );
  };
}
