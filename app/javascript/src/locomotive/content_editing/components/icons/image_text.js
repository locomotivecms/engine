import React from "react";

const ImgText = props => (
  <svg width={21} height={9} {...props}>
    <g fill="none" fillRule="evenodd" transform="translate(0 -1)">
      <path
        stroke="#1C77C3"
        strokeLinecap="round"
        d="M11.25 2.357h9m-9 3.143h9m-9 3.143h6"
      />
      <rect
        width={8}
        height={6.857}
        x={0.5}
        y={2.071}
        stroke="#35373B"
        rx={1}
      />
    </g>
  </svg>
);

export default ImgText;
