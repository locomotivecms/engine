import React from 'react';

// Components
import Section from './section';

const List = props => {
  return (
    <div className="editor-section-list">
      {props.list.map(section =>
        <Section
          key={section.id}
          section={section}
          definition={props.findSectionDefinition(section.type)}
          editPath={props.editSectionPath(section)}
        />
      )}
    </div>
  )
}

export default List;
