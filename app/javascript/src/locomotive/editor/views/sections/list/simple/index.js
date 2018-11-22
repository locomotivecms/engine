import React from 'react';

// Services
import { fetchSectionContent, findBetterImageAndText } from '../../../../services/sections_service';

// Components
import Section from './section';

const List = props => (
  <div className="editor-section-list">
    {props.list.map((section, index) => {
      const definition = props.findSectionDefinition(section.type);

      // Don't let the app crash if we don't have the definition of a section
      if (definition === undefined) return null;

      const sectionContent    = fetchSectionContent(props.globalContent, section);
      const { image, text }   = findBetterImageAndText(sectionContent, definition)

      // add a separator between 2 sections that have different sources
      // (we don't want to mix global sections with page ones)
      const separator = index > 0 && props.list[index - 1].source !== section.source;

      return (
        <Section
          key={section.id}
          image={image}
          text={text}
          section={section}
          sectionContent={sectionContent}
          definition={definition}
          editPath={props.editSectionPath(section)}
          separator={separator}
          {...props}
        />
      )
    })}
  </div>
)

export default List;
