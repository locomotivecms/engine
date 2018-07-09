import React, { Component } from 'react';
import { isBlank } from '../../utils/misc';

const UrlInfo = ({ value, handleEditing }) => (
  <div className="url-picker-info">
    {isBlank(value) ? (
      <div className="url-picker-info-value">No URL for now</div>
    ) : (
      <div className="url-picker-info-value">
        <span className="label label-primary">{value.label[0]}</span>
        &nbsp;
        {value.label[1]}
      </div>
    )}
    <div className="url-picker-info-actions">
      <button className="btn btn-sm btn-primary" onClick={handleEditing}>
        Change
      </button>
    </div>
  </div>
)

export default UrlInfo;
