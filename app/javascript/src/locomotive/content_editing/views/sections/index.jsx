import React from 'react';

// HOC
import withGlobalVars from '../../hoc/with_global_vars';

// Components
import StaticList from './index/static_list.jsx';
import List from './index/list.jsx';

const Index = ({ sections, ...props }) => (
  <div className="editor-all-sections">
    {!sections.dropzone && <StaticList list={sections.all} />}

    {sections.dropzone && (
      <div>
        {sections.top.length > 0 && <StaticList list={sections.top} />}

        <List />

        {sections.bottom.length > 0 && <StaticList list={sections.bottom} />}
      </div>
    )}
  </div>
)

export default withGlobalVars(Index);
