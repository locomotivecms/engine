import React, { Component } from 'react';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';
import { bindAll } from 'lodash';
import i18n from '../../../../i18n';

// Services
import { findBetterImageAndText } from '../../../../services/sections_service';

// Components
import { SlideLeftLink } from '../../../../components/links';
import Section from './section';

const DragHandle      = SortableHandle(() => (
  <div className="editor-list-item--drag-handle"><i className="fa fa-bars"></i></div>
));
const SortableSection = SortableElement(Section);
const SortableList    = SortableContainer(({ list, ...props }) => {
  return (
    <div>
      {(list || []).map((section, index) => {
        const definition        = props.findSectionDefinition(section.type);
        const { image, text }   = findBetterImageAndText(section, definition)

        return (
          <SortableSection
            key={`section-${section.id}`}
            index={index}
            image={image}
            text={text}
            section={section}
            definition={definition}
            editPath={props.editSectionPath(section)}
            handleComponent={DragHandle}
          />
        )}
      )}
    </div>
  );
});

export class Dropzone extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'onSortEnd');
  }

  onSortEnd({ oldIndex, newIndex }) {
    this.props.moveSection(
      oldIndex,
      newIndex,
      this.props.list[oldIndex],
      this.props.list[newIndex]
    );
  }

  render() {
    return (
      <div className="editor-section-list">
        <SortableList
          list={this.props.list}
          onSortEnd={this.onSortEnd}
          useDragHandle={true}
          lockAxis="y"
          {...this.props}
        />

        <div className="editor-list-add">
          <SlideLeftLink to={this.props.newSectionPath()} className="editor-list-add--button">
            {i18n.t('views.sections.dropzone.add')}
          </SlideLeftLink>
        </div>
      </div>
    )
  }

}

export default Dropzone;
