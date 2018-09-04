import React from 'react';
import buildRoutes from './utils/routes_builder';

// Views
import SectionsList from './views/sections/list';
import SectionGallery from './views/sections/gallery';
import EditSection from './views/sections/edit';
import EditBlock from './views/blocks/edit';
import ImagesIndex from './views/assets/images';

import Settings from './views/settings';
import Seo from './views/seo';

const nestedRoutes = {
  '/:pageId/content/edit/settings': Settings,
  '/:pageId/content/edit/seo': Seo,

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
