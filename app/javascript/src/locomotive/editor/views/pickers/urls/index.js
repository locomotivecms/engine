import React, { Component } from 'react';
import { compose } from 'redux';
import { bindAll, debounce } from 'lodash';
import i18n from '../../../i18n';

// HOC
import asView from '../../../hoc/as_view';
import withRedux from '../../../hoc/with_redux';

// Components
import Modal from '../../../components/modal';
import View from '../../../components/default_view';
import Main from './main';

class Index extends Component {

  constructor(props) {
    super(props);
    this._updateContent = debounce(this.updateContent, 500);
  }

  updateContent(type, settings) {
    const { handleChange, settingType, settingId } = this.props;
    handleChange(settingType, settingId, { ...settings, type });
  }

  render() {
    return (
      <View
        title={i18n.t('views.pickers.url.title')}
        subTitle={this.props.settingLabel}
        onLeave={this.props.leaveView}
      >
        <Main
          url={this.props.currentContent.settings[this.props.settingId]}
          updateContent={(type, settings) => this._updateContent(type, settings)}
          {...this.props}
        />
      </View>
    )
  }

}

export default compose(
  asView,
  withRedux(state => ({ contentTypes: state.editor.contentTypes }))
)(Index);
