import React from 'react';
import buildRoutes from './utils/routes_builder';

// HOC
import withHeader from './hoc/with_header';

// Views
import _EditableElementsIndex from './views/editable_elements/list.jsx';
import _SectionsIndex from './views/sections/index.jsx';
import SectionGallery from './views/sections/gallery.jsx';
import EditSection from './views/sections/edit.jsx';
import EditBlock from './views/blocks/edit.jsx';
import ImagesIndex from './views/assets/images/index.jsx';

const SectionsIndex         = withHeader(_SectionsIndex);
const EditableElementsIndex = withHeader(_EditableElementsIndex)

const nestedRoutes = {
  // Static Sections
  '/sections': {
    component: SectionsIndex,
    '/:sectionType': {
      '/edit': EditSection,
      '/setting/:settingType/:settingId/images': ImagesIndex,
      '/blocks/:blockType/:blockId': {
        '/edit': EditBlock,
        '/setting/:settingType/:settingId/images': ImagesIndex
      }
    }
  },

  // Dropzone sections
  '/dropzone_sections': {
    '/pick': SectionGallery,
    '/:sectionType/:sectionId': {
      '/edit': EditSection,
      '/setting/:settingType/:settingId/images': ImagesIndex,
      '/blocks/:blockType/:blockId': {
        '/edit': EditBlock,
        '/setting/:settingType/:settingId/images': ImagesIndex
      }
    }
  },

  // Editable elements
  '/editable_elements': EditableElementsIndex
}

export default buildRoutes(nestedRoutes);
