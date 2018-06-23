import React, { Component } from 'react';
import { bindAll } from 'lodash';

// HOC
import withRedux from '../hoc/with_redux';

// Services
import { saveContent } from '../services/api';

class SaveButton extends React.Component {

  constructor(props) {
    super(props);
    bindAll(this, 'save');
  }

  save() {
    const { persistChanges, site, page } = this.props;

    saveContent(site, page)
    .then((data) => { persistChanges(true) })
    .catch((errors) => { persistChanges(false, errors) });
  }

  render() {
    return <button
      className="btn btn-primary btn-sm"
      onClick={this.save}
    >
      Save
    </button>
  }

}

export default withRedux(state => ({ site: state.site, page: state.page }))(SaveButton);
