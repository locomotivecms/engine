import React, { Component } from 'react';
import { bindAll } from 'lodash';

class Preset extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'selectPreset', 'previewPreset');
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

export default Preset;
