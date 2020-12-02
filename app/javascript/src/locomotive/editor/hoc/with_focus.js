import React from 'react';
import { bindAll } from 'lodash';

// Since animations are used, the component can be rendered multiple times 
// during the transition. To avoid flickering on the focused input, 
// we wait until the state is "stabilized".
export default function withFocus(Component) {

  const useFocus = () => {
    const ref = React.createRef()
    const setFocus = () => ref.current && ref.current.focus();
    return { setFocus, ref } 
  }

  return class WrappedComponent extends React.Component {

    constructor(props) {
      super(props);
      this.inputFocus = useFocus(props.hasFocus);
      this.timeout = null;
    }

    componentDidUpdate(prevProps) {
      if (prevProps.hasFocus !== this.props.hasFocus && this.timeout)
        clearTimeout(this.timeout)

      if (this.props.hasFocus)
        this.timeout = setTimeout(() => this.inputFocus.setFocus(), 50);      
    }

    render() {
      return (
        <Component
          inputFocus={this.inputFocus}
          {...this.props}
        />
      )
    }
  }

}
