import React from 'react';

const HintInput = ({ label }) => (
  <div className="editor-input editor-input-hint">
    <label className="editor-input--label" dangerouslySetInnerHTML={{ __html: label }} />
  </div>
)

export default HintInput;
