import React, { Component } from 'react';
import { bindAll, debounce } from 'lodash';
import Popover from 'react-awesome-popover';
import { isBlank } from '../../utils/misc';

// Components
import UrlPickerResource from './resource.jsx';

class UrlInput extends Component {

  constructor(props) {
    super(props);
    this.state = { results: [], input: null };
    bindAll(this, 'handleKeyUp', 'handleChange');
    this.searchForResources = debounce(this.searchForResources, 500);
  }

  componentWillUnmount() {
    this.searchForResources.cancel();
  }

  handleKeyUp(event) {
    this.setState({ input: event.target.value });
    this.searchForResources(event.target.value);
  }

  searchForResources(query) {
    this.props.searchForResources(query).then(response =>
      this.setState({ results: response.list })
    );
  }

  handleSelect(resource) {
    this.props.handleChange(resource);
  }

  handleChange() {
    this.props.handleChange({
      type:   '_external',
      value:  this.state.input,
      label:  ['external', this.state.input]
    });
  }

  getDefaultValue() {
    return this.props.value.type === '_external' ? this.props.value.value : null;
  }

  render() {
    const { handleCancel } = this.props;

    return (
      <div className="url-picker-input">
        <div className="url-picker-input-autocomplete">
          <Popover placement="bottom" action={null} open={this.state.results.length > 0}>
            <input
              type="text"
              onKeyUp={this.handleKeyUp}
              defaultValue={this.getDefaultValue()}
              placeholder="Please type the label of a resource"
            />
            <div className="rap-popover-pad">
              {this.state.results.map((resource, index) => (
                <UrlPickerResource
                  key={`url-picker-resource-${index}`}
                  resource={resource}
                  handleSelect={() => this.handleSelect(resource)}
                />
              ))}
            </div>
          </Popover>
        </div>
        <div className="url-picker-input-actions">
          {!isBlank(this.state.input) && isBlank(this.state.results) && (
            <button className="btn btn-sm btn-primary" onClick={this.handleChange}>
              Select
            </button>
          )}
          <button className="btn btn-sm btn-primary" onClick={handleCancel}>
            Cancel
          </button>
        </div>
      </div>
    )
  }

}

export default UrlInput;
