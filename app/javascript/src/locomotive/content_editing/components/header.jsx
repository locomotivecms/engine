import React from 'react';
import { compose } from 'redux';
import { Link } from 'react-router-dom';

// Hoc
import withGlobalVars from '../hoc/with_global_vars';
import withRedux from '../hoc/with_redux';

// Components
import SaveButton from './save_button.jsx';

const isActive = (name, props) => {
  if (props.match === undefined) return false;

  if (props.match.path === '/')
    return name === 'sections' && props.hasSections;
  else
    return RegExp(`^/${name}`).test(props.match.path);
}

const Header = (props) => (
  <div className="row header-row">
    <div className="col-md-12">
      <h1>{props.page.title}</h1>
    </div>
    <div className="col-md-9">
      <ul className="nav nav-tabs" role="tablist">
        <li className={isActive('sections', props) ? 'active' : ''}>
          <Link to={props.sectionsPath()}>Sections</Link>
        </li>
        <li className={isActive('editable_elements', props) ? 'active' : ''}>
          <Link to={props.editableElementsPath()}>Content</Link>
        </li>
        <li>
          <a role="tab" href={props.urls.settings}>Settings</a>
        </li>
      </ul>
    </div>
    <div className="col-md-3">
      <SaveButton />
    </div>
  </div>
)

export default compose(
  withRedux(state => ({ page: state.page })),
  withGlobalVars
)(Header)

