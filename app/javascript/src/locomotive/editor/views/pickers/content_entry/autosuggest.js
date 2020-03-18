import React, { Component } from 'react';
import { bindAll } from 'lodash';
import classnames from 'classnames';
import { isBlank } from '../../../utils/misc';

// Components
import ReactAutosuggest from 'react-autosuggest';

// Helpers
const getSuggestionValue = suggestion => suggestion;
const renderSuggestion = suggestion => <span>{suggestion.label[1]}</span>
const getInputText = suggestion => {
  return (suggestion && suggestion.label ? suggestion.label[1] : null) || '';
}

class Autosuggest extends Component {

  constructor(props) {
    super();
    this.state = { input: null, suggestions: [], loading: false };
    bindAll(this, 'onChange', 'onSuggestionsFetchRequested', 'onSuggestionsClearRequested');
  }

  componentDidMount() {
    this.setState({ input: this.props.input });
  }

  componentDidUpdate(prevProps) {
    if (this.props.input !== prevProps.input)
      this.setState({ input: this.props.input });
  }

  onChange(event, { newValue, method }) {
    switch(method) {
      case 'enter':
      case 'click':
        this.setState({ input: getInputText(newValue) }, () => {
          this.props.handleChange(newValue);
        });
        return;
      case 'type':
        this.setState({ input: newValue }, () => {
          this.props.handleNewInput();
        });
      default:
        // do nothing
    }
  }

  onSuggestionsFetchRequested({ value }) {
    this.setState({ loading: true });
    this.props.search(value)
    .then(data => this.setState({ suggestions: data.list, loading: false }));
  }

  onSuggestionsClearRequested() {
    this.setState({ suggestions: [] });
  }

  render() {
    const { input, suggestions, loading } = this.state;
    const inputProps = {
      placeholder:  this.props.placeholder,
      value:        input || '',
      onChange:     this.onChange
    };

    return (
      <div className="editor-input editor-input-text">
        <label className="editor-input--label">
          {this.props.label}
        </label>
        <div className={classnames('react-autosuggest', loading && 'react-autosuggest--loading')}>
          <div className="react-autosuggest__spinner">
            <i className="fas fa-circle-notch fa-spin"></i>
          </div>
          <ReactAutosuggest
            suggestions={suggestions}
            onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
            onSuggestionsClearRequested={this.onSuggestionsClearRequested}
            getSuggestionValue={getSuggestionValue}
            renderSuggestion={renderSuggestion}
            inputProps={inputProps}
          />
        </div>
      </div>
    );
  }

}

export default Autosuggest


