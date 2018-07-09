import React, { Component } from 'react';

const UrlPickerResource = ({ resource, handleSelect }) => (
  <div className="url-picker-resource" onClick={handleSelect}>
    <span className="label label-primary">{resource.label[0]}</span>
    &nbsp;
    {resource.label[1]}
  </div>
)

export default UrlPickerResource;
