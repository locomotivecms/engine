import React, { Component } from 'react';
import { compose } from 'redux';
import i18n from '../i18n';

// HOC
import { withRouter } from 'react-router-dom';
import withRoutes from '../hoc/with_routes';
import withRedux from '../hoc/with_redux';

const openLibrary = props => {
  props.redirectTo(props.pickAssetPath(
    props.section,
    props.blockType,
    props.blockId,
    props.setting.type,
    props.setting.id
  ), 'left');
}

const getFilename = asset => {
  return asset.url.split('/').pop();
}

class AssetPickerInput extends Component {

  render() {
    const { setting, getValue, label, handleChange } = this.props;
    const value = getValue(null);
    const asset = value && typeof(value) === 'object' ? value : { url: value };

    return (
      <div className="editor-input editor-input-asset-picker">
        <label className="editor-input--label">
          {label}
        </label>

        <div className="editor-input--asset-picker">
          {value && (<div className="editor-input-asset-picker--filename">
            <a href={value.url} target="_blank">{getFilename(asset)}</a>
          </div>)}

          <div className="editor-input-asset-picker--actions">
            <button className="btn btn-default btn-sm" onClick={e => openLibrary({ setting, ...this.props })}>
              {i18n.t(value === null ? 'inputs.asset_picker.select_button' : 'inputs.asset_picker.change_button')}
            </button>
            &nbsp;
            {value !== null && (
              <button
                className="btn btn-default btn-sm"
                onClick={e => handleChange(null)}
              >
                {i18n.t('inputs.asset_picker.remove_button')}
              </button>
            )}        
          </div>
        </div>
      </div>
    )
  }

}

export default compose(
  withRouter,
  withRoutes,
  withRedux(state => ({ thumbnailPath: state.editor.urls.thumbnail }))
)(AssetPickerInput);
