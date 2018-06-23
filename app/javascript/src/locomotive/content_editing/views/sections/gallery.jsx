import React, { Component } from 'react';
import { compose } from 'redux';
import withRedux from '../../hoc/with_redux';
import withGlobalVars from '../../hoc/with_global_vars';
import { bindAll } from 'lodash';

// Components
import Category from './gallery/category.jsx';

// Services
import { buildSection, buildCategories } from '../../services/sections_service';

class Gallery extends Component {

  constructor(props) {
    super(props);
    this.state      = { category: null, preset: null, section: null };
    this.categories = buildCategories(props.sectionDefinitions);
    bindAll(this, 'selectPreset', 'previewPreset', 'cancel');
  }

  selectedPreset() {
    if (this.state.category === null) return null;
    return [this.state.preset.type, this.state.category.id, this.state.preset.id].join('-');
  }

  cancel() {
    this.props.cancelPreviewSection();
    this.props.history.push('/sections');
  }

  selectPreset() {
    const { section } = this.state;

    this.props.addSection(section);

    // Go directly to the section edit page
    this.props.history.push(`/dropzone_sections/${section.type}/${section.id}/edit`);
  }

  previewPreset(category, preset) {
    const { definitions } = this.props;
    const section = buildSection(definitions, preset.type, preset.preset);

    this.setState({ category, preset, section }, () => {
      this.props.previewSection(section);
    });
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
            selectPreset={this.selectPreset}
            previewPreset={this.previewPreset}
            selectedPreset={this.selectedPreset()}
            {...this.props}
          />
        )}
      </div>
    )
  }

}

export default compose(
  withRedux(),
  withGlobalVars
);
