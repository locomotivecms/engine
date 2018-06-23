import React, { Component } from 'react';
import { compose } from 'redux';
import { Link } from 'react-router-dom';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';
import { bindAll } from 'lodash';

// HOC
import withRedux from '../../../hoc/with_redux';
import withGlobalVars from '../../../hoc/with_global_vars';

// Components
import Section from './section.jsx';

const DragHandle      = SortableHandle(() => <span>::</span>);
const SortableSection = SortableElement(Section);
const SortableList    = SortableContainer(({ list, removeSection, ...props }) => {
  return (
    <div>
      {(list || []).map((section, index) =>
        <SortableSection
          key={`section-${section.id}`}
          index={index}
          section={section}
          editPath={props.editSectionPath(section.type, section.id)}
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
    bindAll(this, 'onSortEnd');
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
          list={this.props.list}
          onSortEnd={this.onSortEnd}
          useDragHandle={true}
          lockAxis="y"
          {...this.props}
        />

        {this.props.list.length === 0 && (
          <div className="editor-section-none text-center">
            No section
          </div>
        )}

        <div className="editor-section-add-section text-center">
          <Link to={this.props.newSectionPath()}>Add section</Link>
        </div>
      </div>
    )
  }

}

export default compose(
  withRedux(state => ({ list: state.page.sectionsContent })),
  withGlobalVars
)(List)
