import React from 'react';
import { compose } from 'redux';

// HOC
import withRedux from '../../../hoc/with_redux';
import withRoutes from '../../../hoc/with_routes';
import withGlobalVars from '../../../hoc/with_global_vars';

// Components
import SimpleList from './simple';
import Dropzone from './dropzone';

// const Index = ({ sections, ...props }) => (
//   <div className="editor-all-sections">
//     {!sections.dropzone && <StaticList list={sections.all} />}

//     {sections.dropzone && (
//       <div>
//         {sections.top.length > 0 && <StaticList list={sections.top} />}

//         <List />

//         {sections.bottom.length > 0 && <StaticList list={sections.bottom} />}
//       </div>
//     )}
//   </div>
// )

// {!sections.dropzone && <List list={sections.all} {...props} />}

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
