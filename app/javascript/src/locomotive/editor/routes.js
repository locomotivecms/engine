import React from 'react';
import buildRoutes from './utils/routes_builder';

// Views
import Main from './views/action_bar/main';
import SectionGallery from './views/sections/gallery';
import EditSection from './views/sections/edit';
import EditBlock from './views/blocks/edit';
import ImagesIndex from './views/pickers/images';
import UrlsIndex from './views/pickers/urls';

const nestedRoutes = {
  '/:pageId/content/edit': {
    component: Main,
    '/sections/dropzone/new': SectionGallery,
    '/sections/:sectionId': {
      '/edit': EditSection,
      '/setting/:settingType/:settingId/images': ImagesIndex,
      '/setting/:settingType/:settingId/pick-url': UrlsIndex,
      '/blocks/:blockType/:blockId': {
        '/edit': EditBlock,
        '/setting/:settingType/:settingId/images': ImagesIndex,
        '/setting/:settingType/:settingId/pick-url': UrlsIndex
      }
    }
  }
}

export default buildRoutes(nestedRoutes);
