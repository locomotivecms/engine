import React, { Component } from 'react';
import { bindAll } from 'lodash';
import i18n from '../../../i18n';

// Components
import Icons from '../../../components/icons';

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
    const Icon = Icons[this.props.preset.icon || this.props.definition.icon] || Icons.default;

    return (
      <div className="editor-list-item">
        <div className="editor-list-item--icon editor-category-section--icon" onClick={this.previewPreset}>
          {Icon && <Icon />}
        </div>
        <div className="editor-list-item--label editor-category-section--label" onClick={this.previewPreset}>
          {this.props.preset.name}
        </div>
        <div className="editor-list-item--actions">
          {this.isSelected() &&
            <button className="btn btn-primary btn-sm" onClick={this.selectPreset}>
              {i18n.t('views.sections.gallery.add')}
            </button>
          }
        </div>
      </div>
    )
  }

}

export default Preset;
