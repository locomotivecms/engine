import React from 'react';

const state = { urls: {} };

export const UrlsContext = React.createContext(state.urls);
