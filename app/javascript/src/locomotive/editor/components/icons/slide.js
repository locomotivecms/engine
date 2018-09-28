import React from "react";

const Slide = props => (
  <svg width={24} height={10} {...props}>
    <g fill="none" fillRule="evenodd">
      <path
        stroke="#1C77C3"
        strokeLinecap="round"
        d="M21 3l2 2m0 0l-2 2M3 3L1 5m0 0l2 2"
      />
      <rect width={11} height={9} x={6.5} y={0.5} stroke="#35373B" rx={1} />
    </g>
  </svg>
);

export default Slide;
