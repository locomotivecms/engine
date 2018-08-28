import React from 'react';
import { compose } from 'redux';
import { isBlank } from '../../../utils/misc';

// HOC
import withRedux from '../../../hoc/with_redux';
import withRoutes from '../../../hoc/with_routes';
import withGlobalVars from '../../../hoc/with_global_vars';

// Components
import SimpleList from './simple';
import Dropzone from './dropzone';

const Index = ({ sections, dropzoneContent, ...props }) => (
  <div className="editor-all-sections">
    {!isBlank(sections.top) && <SimpleList list={sections.top} {...props} />}

    {sections.dropzone && <Dropzone list={dropzoneContent} {...props} />}

    {!isBlank(sections.bottom) && <SimpleList list={sections.bottom} {...props} />}
  </div>
);

export { Index }; // Used for testing

export default compose(
  withRedux(state => ({
    site:             state.content.site,
    page:             state.content.page,
    dropzoneContent:  state.content.page.sectionsDropzoneContent
  })),
  withGlobalVars,
  withRoutes
)(Index);
