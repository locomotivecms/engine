import React from 'react';

const Default = props => (
  <svg width={20} height={20} {...props}>
    <g stroke="#07356B" fill="none" fillRule="evenodd">
      <rect x={0.5} y={0.5} width={19} height={19} rx={2} />
      <path d="M4.92 11.333h10.16M4.92 8.667h10.16" strokeLinecap="round" />
    </g>
  </svg>
);

export default Default;
