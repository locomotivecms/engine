import React, { Component } from 'react';

const UrlPickerResource = ({ resource, handleSelect }) => (
  <div className="url-picker-resource" onClick={handleSelect}>
    <div className="url-picker-resource--type">
      <span className="label label-primary">{resource.label[0]}</span>
    </div>
    <div className="url-picker-resource--label">
      {resource.label[1]}
    </div>
  </div>
)

export default UrlPickerResource;
