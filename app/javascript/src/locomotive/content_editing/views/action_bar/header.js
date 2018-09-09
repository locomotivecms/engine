import React, { Component } from 'react';

// HOC
import withRedux from '../../hoc/with_redux';

// Components
import Button from '../../components/button';

const Header = props => (
  <div className="editor-header">
    <div className="editor-header--navinfo">
      <div className="navinfo--path">
        {props.page.fullpath}
      </div>
      <div className="navinfo--title">
        {props.page.title || 'No title'}
      </div>
    </div>

    <div className="editor-header--savebtn">
      <Button
        mainClassName="btn-save"
        className="btn btn-primary"
        onClick={props.persistChanges}
        disabled={!props.changed}
        label="Save"
        inProgressLabel="Saving..."
        successLabel="Changes saved"
        errorLabel="Error :-("
      />
    </div>
  </div>
)

export default withRedux(state => ({
  page:     state.content.page,
  changed:  state.editor.changed
}))(Header)
