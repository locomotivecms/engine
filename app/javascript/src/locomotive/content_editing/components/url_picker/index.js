import React, { Component } from 'react';
import { bindAll } from 'lodash';

// Components
import UrlInput from './input.jsx';
import UrlInfo from './info.jsx';

class UrlPicker extends Component {

  constructor(props) {
    super(props);
    this.state = { editing: props.editing || false };
    bindAll(this, 'handleEditing', 'handleChange', 'handleCancel');
  }

  handleEditing() {
    this.setState({ editing: true });
  }

  handleCancel() {
    this.setState({ editing: false });
  }

  handleChange(resource) {
    this.setState({ editing: false });
    this.props.handleChange(resource);
  }

  getValue() {
    const value = this.props.value;

    if (typeof(value) === 'string') {
      return { type: '_external', value, label: ['external', value] };
    } else
      return value;
  }

  render() {
    return (
      <div className="url-picker">
        {this.state.editing ? (
          <UrlInput
            handleChange={this.handleChange}
            handleCancel={this.handleCancel}
          />
        ) : (
          <UrlInfo
            value={this.getValue()}
            handleEditing={this.handleEditing}
          />
        )}
      </div>
    )
  }

}

export default UrlPicker;


// const UrlInfo = ({ value, handleEditing }) => (
//   <div className="url-info">
//     {isBlank(value) ? (
//       <div className="url-info-value">No URL for now</div>
//     ) : (
//       <div className="url-info-value">
//         <span className="label label-primary">{value.label[0]}</span>
//         &nbsp;
//         {value.label[1]}
//       </div>
//     )}
//     <div className="url-info-actions">
//       <button className="btn btn-sm btn-primary" onClick={handleEditing}>
//         Change
//       </button>
//     </div>
//   </div>
// )

// const UrlPickerResource = ({ resource, handleSelect }) => (
//   <div className="url-picker-resource" onClick={handleSelect}>
//     <span className="label label-primary">{resource.label[0]}</span>
//     &nbsp;
//     {resource.label[1]}
//   </div>
// )

// class UrlPicker extends Component {

//   constructor(props) {
//     super(props);
//     this.state = { results: [], input: null };
//     bindAll(this, 'handleKeyUp', 'handleChange');
//     this.searchForResources = debounce(this.searchForResources, 500);
//   }

//   handleKeyUp(event) {
//     this.setState({ input: event.target.value });
//     this.searchForResources(event.target.value);
//   }

//   searchForResources(query) {
//     Api.searchForResources(query).then(response =>
//       this.setState({ results: response.list })
//     );
//   }

//   handleSelect(resource) {
//     this.props.handleChange(resource);
//   }

//   handleChange() {
//     this.props.handleChange({
//       type:   '_external',
//       value:  this.state.input,
//       label:  ['external', this.state.input]
//     });
//   }

//   render() {
//     const { handleCancel } = this.props;

//     return (
//       <div className="url-picker">
//         <div className="url-picker-autocomplete">
//           <Popover placement="bottom" action={null} open={this.state.results.length > 0}>
//             <input
//               type="text"
//               onKeyUp={this.handleKeyUp}
//               placeholder="Please type the label of a resource"
//             />
//             <div className="rap-popover-pad">
//               {this.state.results.map((resource, index) => (
//                 <UrlPickerResource
//                   key={`url-picker-resource-${index}`}
//                   resource={resource}
//                   handleSelect={() => this.handleSelect(resource)}
//                 />
//               ))}
//             </div>
//           </Popover>
//         </div>
//         <div className="url-picker-actions">
//           {!isBlank(this.state.input) && isBlank(this.state.results) && (
//             <button className="btn btn-sm btn-primary" onClick={this.handleChange}>
//               Select
//             </button>
//           )}
//           <button className="btn btn-sm btn-primary" onClick={handleCancel}>
//             Cancel
//           </button>
//         </div>
//       </div>
//     )
//   }

// }

// export { UrlPicker, UrlInfo };
