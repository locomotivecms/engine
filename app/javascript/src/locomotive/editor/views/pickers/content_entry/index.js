import React, { Component } from 'react';
import { compose } from 'redux';
import { debounce } from 'lodash';
import i18n from '../../../i18n';

// HOC
import asView from '../../../hoc/as_view';

// Components
import View from '../../../components/default_view';
import Main from './main';

class Index extends Component {

  constructor(props) {
    super(props);
    this._updateContent = debounce(this.updateContent, 500);
  }

  updateContent(contentEntry) {
    const { handleChange, settingType, settingId } = this.props;
    handleChange(settingType, settingId, contentEntry);
  }

  render() {
    return (
      <View
        title={i18n.t('views.pickers.content_entry.title')}
        subTitle={this.props.settingLabel}
        onLeave={this.props.leaveView}
      >
        <Main
          contentEntry={this.props.currentContent.settings[this.props.settingId]}
          updateContent={contentEntry => this._updateContent(contentEntry)}
          {...this.props}
        />
      </View>
    )
  }

}

export default compose(
  asView,
)(Index);
