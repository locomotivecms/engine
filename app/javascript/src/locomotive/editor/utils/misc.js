import striptags from 'striptags';

// Constants
const WAIT_UNTIL_MIN_DELAY  = 1000; // we want to avoid the flickering if the iframe is loaded too quickly
const LINK_REGEXP           = /\/_locomotive-link\/(.+)/;

export function waitUntil(startedAt, minDelay, callback) {
  minDelay = minDelay || WAIT_UNTIL_MIN_DELAY;
  var delay = Math.abs(new Date().getMilliseconds() - startedAt);
  delay = delay < minDelay ? minDelay - delay : 0;
  setTimeout(callback, delay);
}

const _isBlank = value => value === undefined || value === null || value === '' || value.length === 0;

export function isBlank(value) {
  return _isBlank(value);
}

export function presence(value) {
  return _isBlank(value) ? null : value;
}

// https://stackoverflow.com/a/8809472
export function uuid() {
  var d = new Date().getTime();
  if (typeof performance !== 'undefined' && typeof performance.now === 'function'){
      d += performance.now(); //use high-precision timer if available
  }
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = (d + Math.random() * 16) % 16 | 0;
    d = Math.floor(d / 16);
    return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
}

export function shortUuid() {
  return Math.random().toString(36).substring(10);
}

// Swap an element of an array to its new position
export function arrayMove(array, oldIndex, newIndex) {
  var newArray = [];

  if (oldIndex === newIndex) return array;

  for (var index = 0; newArray.length < array.length; index++) {
    if (index === newIndex) {
      if (newIndex < oldIndex)
        newArray.push(array[oldIndex], array[index]);
      else
        newArray.push(array[index], array[oldIndex]);
    } else if (index !== oldIndex)
      newArray.push(array[index]);
  }

  return newArray
}

// Replace p tags by br
export function formatLineBreak(text) {
  return text
    .replace(/<\/p>\n<p>/g, '<br>')
    .replace(/<p>/g, '')
    .replace(/<\/p>/g, '');
}

// Strip HTML tags from a string.
export function stripHTML(html) {
  if (_isBlank(html)) return html;

  return striptags(html)
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/(\/n|\/t)+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// parse an integer/float and returns null if it's not an integer
export function toInt(number) {
  if (number === '0') return 0;
  return parseInt(number) || null
}

export function argNames(func) {
  return func.toString().replace(/.*\(|\).*/ig, '').split(',')
}

// https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding

// Encode in Base64
const b64EncodeUnicode = str => {
  return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, (match, p1) => {
    return String.fromCharCode('0x' + p1);
  }));
}

// Decode
const b64DecodeUnicode = str => {
  // Going backwards: from bytestream, to percent-encoding, to original string.
  return decodeURIComponent(atob(str).split('').map(c => {
    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
  }).join(''));
}

export function encodeLinkResource(resource) {
  const parameter = b64EncodeUnicode(JSON.stringify(resource));
  const baseUrl   = window.Locomotive.previewBaseUrl;
  return `${window.location.origin}${baseUrl}/_locomotive-link/${parameter}`;
}

export function decodeLinkResource(url) {
  if (_isBlank(url)) return null;

  const matches = url.match(LINK_REGEXP);

  if (matches && matches.length > 1)
    return JSON.parse(b64DecodeUnicode(matches[1]))
  else
    return null;
}

// DOM

// get the content of a meta tag inside an iframe
export function getMetaContentFromIframe(iframe, name) {
  const meta = iframe.contentWindow.document.head.querySelector(`meta[name=${name}]`);
  return meta ? meta.content : null;
}

export function findParentElement(tagName, el) {
  while (el) {
    if ((el.nodeName || el.tagName).toLowerCase() === tagName) return el;
    el = el.parentNode;
  }
  return null;
}

export function stopPropagation(event) {
  event.stopPropagation();
}

export function cancelEvent(event) {
  event.preventDefault() & event.stopPropagation();
  return false;
}
