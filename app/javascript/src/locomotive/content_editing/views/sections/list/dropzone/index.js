import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';
import { bindAll } from 'lodash';

// Components
import Section from './section';

const DragHandle      = SortableHandle(() => <span className="editor-section--drag-handle">::</span>);
const SortableSection = SortableElement(Section);
const SortableList    = SortableContainer(({ list, removeSection, ...props }) => {
  return (
    <div>
      {(list || []).map((section, index) =>
        <SortableSection
          key={`section-${section.id}`}
          index={index}
          section={section}
          editPath={props.editSectionPath(section)}
          removeSection={removeSection.bind(null, section)}
          handleComponent={DragHandle}
        />
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

        <div className="editor-section-add text-center">
          <Link to={this.props.newSectionPath()} className="editor-section-add--button">+ add section</Link>
        </div>
      </div>
    )
  }

}

export default Dropzone;
