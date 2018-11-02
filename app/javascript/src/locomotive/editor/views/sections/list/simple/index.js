import React from 'react';

// Services
import { fetchSectionContent, findBetterImageAndText } from '../../../../services/sections_service';

// Components
import Section from './section';

const List = props => (
  <div className="editor-section-list">
    {props.list.map(section => {
      const definition = props.findSectionDefinition(section.type);

      // Don't let the app crash if we don't have the definition of a section
      if (definition === undefined) return null;

      const sectionContent    = fetchSectionContent(props.globalContent, section);
      const { image, text }   = findBetterImageAndText(sectionContent, definition)

      return (
        <Section
          key={section.id}
          image={image}
          text={text}
          section={section}
          sectionContent={sectionContent}
          definition={definition}
          editPath={props.editSectionPath(section)}
          {...props}
        />
      )
    })}
  </div>
)

export default List;
