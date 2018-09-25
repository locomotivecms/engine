import React, { Component } from 'react';

class Shield extends Component {

  constructor(props) {
    super(props);
    this.state = { hasError: false, info: null };
  }

  componentDidCatch(hasError, info) {
    this.setState({ hasError, info });
  }

  render() {
    if(this.state.hasError) {
      // Some error was thrown. Let's display something helpful to the user
      return (
        <div className="editor-error-container">
          <div className="editor-error">
            <div className="editor-error-image">
              <img src={this.props.image} />
            </div>

            <div className="editor-error-message">
              <h4 className="editor-error-title">
                We're sorry, but something went wrong.
              </h4>

              <p className="editor-error-text">
                If you are the application owner check the logs for more information.
              </p>
            </div>
          </div>
        </div>
      );
    }
    // No errors were thrown. As you were.
    return this.props.children;
  }
}

export default Shield;
