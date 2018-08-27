import React from 'react';
import buildRoutes from './utils/routes_builder';

// Views
import SectionsList from './views/sections/list';
import SectionGallery from './views/sections/gallery';
import EditSection from './views/sections/edit';
import EditBlock from './views/blocks/edit';
import ImagesIndex from './views/assets/images/index.jsx';

const nestedRoutes = {
  // NEW ROUTES
  '/:pageId/content/edit/sections': {
    component: SectionsList,
    '/dropzone/new': SectionGallery,
    '/:sectionId': {
      '/edit': EditSection,
      '/setting/:settingType/:settingId/images': ImagesIndex,
      '/blocks/:blockType/:blockId': {
        '/edit': EditBlock,
        '/setting/:settingType/:settingId/images': ImagesIndex
      }
    }
  }
}

export default buildRoutes(nestedRoutes);
