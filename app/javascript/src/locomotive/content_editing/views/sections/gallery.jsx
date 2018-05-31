import React, { Component } from 'react';
import withRedux from '../../utils/with_redux';

// Services
import { buildSection, buildCategories } from '../../services/sections_service';

class Section extends Component {

  constructor(props) {
    super(props);

    this.previewSection = this.previewSection.bind(this);
    this.addSection     = this.addSection.bind(this);
  }

  selectedId() {
    return [this.props.category.id, this.props.section.id].join('-');
  }

  isSelected() {
    return this.props.selectedSection === this.selectedId();
  }

  buildSection() {
    const { definitions, section } = this.props;
    return buildSection(definitions, section.type, section.preset);
  }

  previewSection() {
    this.props.previewSection(this.buildSection());

    // required to display the "Add" button
    this.props.onSelect(this.props.category, this.props.section);
  }

  addSection(event) {
    event.stopPropagation(); // don't want to also run previewSection

    const newSection = this.buildSection();

    this.props.addSection(newSection);

    // Go directly to the section edit page
    this.props.history.push(`/dropzone_sections/${newSection.type}/${newSection.id}/edit`);
  }

  render() {
    return (
      <div className="editor-section-category-section" onClick={this.previewSection}>
        {this.props.section.name}
        {this.isSelected() &&
          <span>
            &nbsp;
            <button className="btn btn-primary btn-sm" onClick={this.addSection}>Add</button>
          </span>
        }
      </div>
    )
  }

}

const Category = props => (
  <div className="editor-section-category">
    <div className="editor-section-category-name">
      <h3>{props.category.name}</h3>
    </div>
    <div className="editor-section-category-section-list">
      {props.category.sections.map(section =>
        <Section {...props} key={section.type} section={section} />
      )}
    </div>
  </div>
)

class Gallery extends Component {

  constructor(props) {
    super(props);
    this.state      = {};
    this.categories = buildCategories(props.definitions);
    this.onSelect   = this.onSelect.bind(this);
    this.cancel     = this.cancel.bind(this);
  }

  onSelect(category, section) {
    this.setState({ categoryId: category.id, sectionId: section.id });
  }

  selectedSection() {
    return [this.state.categoryId, this.state.sectionId].join('-');
  }

  cancel() {
    this.props.cancelAddSection();
    this.props.history.push('/sections');
  }

  render() {
    return (
      <div className="editor-section-gallery">
        <div className="row header-row">
          <div className="col-md-12">
            <h1>
              Add section
              &nbsp;
              <small>
                <button className="btn btn-default btn-sm" onClick={this.cancel}>
                  Back
                </button>
              </small>
            </h1>
          </div>
        </div>
        {this.categories.map(category =>
          <Category
            key={category.name}
            category={category}
            onSelect={this.onSelect}
            selectedSection={this.selectedSection()}
            {...this.props}
          />
        )}
      </div>
    )
  }

}

export default withRedux(Gallery, state => { return {
  definitions: state.sectionDefinitions
} });
