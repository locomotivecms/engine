import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import withRedux from '../../../utils/with_redux';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';

// Components
import Section from './section.jsx';

const DragHandle = SortableHandle(() => <span>::</span>);

const SortableSection = SortableElement(Section);

const SortableList = SortableContainer(({ sections, removeSection }) => {
  return (
    <div>
      {(sections || []).map((section, index) =>
        <SortableSection
          key={`section-${section.id}`}
          index={index}
          section={section}
          removeSection={removeSection.bind(null, section.id)}
          handleComponent={DragHandle}
        />
      )}
    </div>
  );
});

export class List extends Component {

  constructor(props) {
    super(props);

    // bind methods to this
    this.onSortEnd  = this.onSortEnd.bind(this);
  }

  onSortEnd({ oldIndex, newIndex }) {
    this.props.moveSection(
      oldIndex,
      newIndex,
      this.props.list[oldIndex].id,
      this.props.list[newIndex].id
    );
  }

  render() {
    return (
      <div className="editor-section-list">
        <SortableList
          sections={this.props.list}
          removeSection={this.props.removeSection}
          onSortEnd={this.onSortEnd}
          useDragHandle={true}
          lockAxis="y"
        />

        {this.props.list.length === 0 && (
          <div className="editor-section-none text-center">
            No section
          </div>
        )}

        <div className="editor-section-add-section text-center">
          <Link to="/dropzone_sections/pick">Add section</Link>
        </div>
      </div>
    )
  }

}

export default withRedux(List, state => { return {
  definitions:  state.sectionDefinitions,
  list:         state.page.sectionsContent
} });
