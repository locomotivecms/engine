import React, { Component } from 'react';
import withRedux from '../../hoc/with_redux';

// Services
import { buildSection, buildCategories } from '../../services/sections_service';

class Preset extends Component {

  constructor(props) {
    super(props);
    this.selectPreset  = this.selectPreset.bind(this);
    this.previewPreset = this.previewPreset.bind(this);
  }

  selectedId() {
    return [this.props.preset.type, this.props.category.id, this.props.preset.id].join('-');
  }

  isSelected() {
    return this.props.selectedPreset === this.selectedId();
  }

  previewPreset() {
    this.props.previewPreset(this.props.category, this.props.preset);
  }

  selectPreset(event) {
    event.stopPropagation(); // don't want to also run previewSection
    this.props.selectPreset();
  }

  render() {
    return (
      <div className="editor-section-category-section" onClick={this.previewPreset}>
        {this.props.preset.name}
        {this.isSelected() &&
          <span>
            &nbsp;
            <button className="btn btn-primary btn-sm" onClick={this.selectPreset}>Add</button>
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
      {props.category.presets.map(preset =>
        <Preset
          {...props}
          key={preset.type}
          preset={preset}
        />
      )}
    </div>
  </div>
)

class Gallery extends Component {

  constructor(props) {
    super(props);
    this.state            = { category: null, preset: null, section: null };
    this.categories       = buildCategories(props.definitions);
    this.selectPreset     = this.selectPreset.bind(this);
    this.previewPreset    = this.previewPreset.bind(this);
    this.cancel           = this.cancel.bind(this);
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

export default withRedux(state => { return {
  definitions: state.sectionDefinitions
} })(Gallery);
