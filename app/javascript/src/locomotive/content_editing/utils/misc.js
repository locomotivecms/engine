export function waitUntil(startedAt, minDelay, callback) {
  var delay = Math.abs(new Date().getMilliseconds() - startedAt);
  delay = delay < minDelay ? minDelay - delay : 0;
  setTimeout(callback, delay);
}
