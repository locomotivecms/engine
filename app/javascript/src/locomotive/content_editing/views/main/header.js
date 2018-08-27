import React, { Component } from 'react';

// HOC
import withRedux from '../../hoc/with_redux';

const Header = props => (
  <div className="editor-header">
    <div className="editor-header--navinfo">
      <div className="navinfo--path">
        {props.page.fullpath}
      </div>
      <div className="navinfo--title">
        {props.page.title}
      </div>
    </div>

    <div className="editor-header--savebtn">
      <button
        className="btn btn-primary"
        onClick={props.persistChanges}
        disabled={!props.changed}
      >
        Save
      </button>
    </div>
  </div>
)

export default withRedux(state => ({
  page:     state.content.page,
  changed:  state.editor.changed
}))(Header)
