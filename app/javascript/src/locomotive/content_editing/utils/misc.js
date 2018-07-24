// we want to avoid the flickering if the iframe is loaded too quickly
const WAIT_UNTIL_MIN_DELAY = 1000;

export function waitUntil(startedAt, minDelay, callback) {
  minDelay = minDelay || WAIT_UNTIL_MIN_DELAY;
  var delay = Math.abs(new Date().getMilliseconds() - startedAt);
  delay = delay < minDelay ? minDelay - delay : 0;
  setTimeout(callback, delay);
}

export function isBlank(value) {
  return value === undefined || value === null || value === '' || value.length === 0;
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
export function b64EncodeUnicode(str) {
  return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, (match, p1) => {
    return String.fromCharCode('0x' + p1);
  }));
}

//
export function b64DecodeUnicode(str) {
  // Going backwards: from bytestream, to percent-encoding, to original string.
  return decodeURIComponent(atob(str).split('').map(c => {
    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
  }).join(''));
}

// get the content of a meta tag inside an iframe
export function getMetaContentFromIframe(iframe, name) {
  return iframe.contentWindow.document.head.querySelector(`meta[name=${name}]`).content;
}
