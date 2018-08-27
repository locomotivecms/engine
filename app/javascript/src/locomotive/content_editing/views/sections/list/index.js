import React from 'react';
import { compose } from 'redux';

// HOC
import withRedux from '../../../hoc/with_redux';
import withRoutes from '../../../hoc/with_routes';
import withGlobalVars from '../../../hoc/with_global_vars';

// Components
import SimpleList from './simple';
import Dropzone from './dropzone';

const Index = ({ sections, dropzoneContent, ...props }) => (
  <div className="editor-all-sections">
    {sections.top.length > 0 && <SimpleList list={sections.top} {...props} />}

    <Dropzone list={dropzoneContent} {...props} />

    {sections.bottom.length > 0 && <SimpleList list={sections.bottom} {...props} />}
  </div>
);

export default compose(
  withRedux(state => ({
    site:             state.content.site,
    page:             state.content.page,
    dropzoneContent:  state.content.page.sectionsDropzoneContent
  })),
  withGlobalVars,
  withRoutes
)(Index);
