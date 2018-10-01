import React from 'react';

const Text = props => (
  <svg width={10} height={5} {...props}>
    <g fill="none" fillRule="evenodd" strokeLinecap="round">
      <path d="M.714 2.5h8.572M.714 4.5h8.572" stroke="#35373B" />
      <path d="M.7.5h4.8" stroke="#1C77C3" />
    </g>
  </svg>
);

export default Text;
