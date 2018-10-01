import React, { Component } from 'react';

// Components
import ResourceLabel from './resource_label';

const UrlPickerResource = ({ resource, handleSelect }) => (
  <div className="url-picker-resource" onClick={handleSelect}>
    <div className="url-picker-resource--type">
      <ResourceLabel value={resource.label[0]} />
    </div>
    <div className="url-picker-resource--label">
      {resource.label[1]}
    </div>
  </div>
)

export default UrlPickerResource;
