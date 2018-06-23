import React from 'react';

// HOC
import withGlobalVars from '../../../hoc/with_global_vars';

// Components
import StaticSection from './static_section.jsx';

const StaticList = props => (
  <div className="editor-section-static-list">
    {props.list.map(type =>
      <StaticSection
        key={type}
        sectionType={type}
        definition={props.findSectionDefinition(type)}
        editPath={props.editStaticSectionPath(type)}
      />
    )}
  </div>
)

export default withGlobalVars(StaticList);
