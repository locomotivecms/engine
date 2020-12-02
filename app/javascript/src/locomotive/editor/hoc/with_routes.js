import React from 'react';
import { bindAll } from 'lodash';

export default function withRoutes(Component) {

  return class WrappedComponent extends React.Component {

    constructor(props) {
      super(props);
      bindAll(this, 'redirectTo');
    }

    // NOTE: slideDirection is the direction where the new view will move to
    redirectTo(pathname, slideRediction, hash) {
      this.props.history.push({ pathname, hash, state: { slideDirection: slideRediction || 'right' } });
    } 

    render() {
      return (
        <Component
          redirectTo={this.redirectTo}
          {...this.props.routes}
          {...this.props}
        />
      )
    }
  }

}
