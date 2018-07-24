import React from 'react';
import { compose } from 'redux';

// HOC
import withRoutes from '../../../hoc/with_routes';
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
        editPath={props.editSectionPath(type)}
      />
    )}
  </div>
)

export default compose(
  withGlobalVars,
  withRoutes
)(StaticList);
