import { decodeLinkResource, findParentElement, cancelEvent } from '../utils/misc';
import { startsWith } from 'lodash';

const findSection = (_window, sectionId) => {
  const sectionSelector = `[data-locomotive-section-id='${sectionId}'], #locomotive-section-${sectionId}`;
  return $(_window.document).find(sectionSelector);
}

const sendEvent = (elem, type, data) => {
  if (elem === null || elem === undefined) return false;

  // console.log('firing', `locomotive::${type}`, data);

  var event = new CustomEvent(
    `locomotive::${type}`,
    { bubbles: true, detail: data || {} }
  );

  elem.dispatchEvent(event);
}

const scrollTo = (_window, $elem) => {
  if ($elem[0] === undefined) return false;

  $(_window.document).find('html, body').animate({
    scrollTop: $elem.offset().top
  }, 400);
}

const pokeSection = (_window, action, sectionId, blockId) => {
  return new Promise(resolve => {
    var $elem, eventName, eventData;

    if (blockId) {
      const value = `section-${sectionId}-block-${blockId}`;

      $elem     = $(_window.document).find(`[data-locomotive-block='${value}']`);
      eventName = `block::${action}`;
      eventData = { sectionId, blockId };
    } else {
      $elem     = findSection(_window, sectionId);
      eventName = `section::${action}`;
      eventData = { sectionId };
    }

    if (action === 'select' && !$elem.hasClass('no-scroll')){
      scrollTo(_window, $elem);
    }

    sendEvent($elem[0], eventName, eventData);

    resolve(true);
  });
}

// General

export function reload(_window, location) {
  // console.log(reload, _window, location);
  _window.document.location.href = location;
}

export function prepareIframe(_window, onPageChange) {
  _window.document.body.addEventListener('click', event => {
    var link = findParentElement('a', event.target);

    if (link) {
      const url       = link.getAttribute('href');
      const resource  = decodeLinkResource(url);

      // first case: link built by the RTE
      if (resource !== null && resource.type !== '_external')
        return;

      // second case: don't handle urls to an external site
      if (url && url[0] !== '/' && url[0] !== '#') {
        alert("This link cannot be opened inside the editor.");
        return cancelEvent(event);
      }

      if (url && url[0] !== '#' && onPageChange) { onPageChange(); }

      return true;
    }
  })
}

// Actions

export function updateSection(_window, section, html) {
  return new Promise(resolve => {
    var $elem = findSection(_window, section.id);

    sendEvent($elem[0], 'section::unload', { sectionId: section.id });
    $elem.replaceWith(html);

    // find the new element
    $elem = findSection(_window, section.id);
    sendEvent($elem[0], 'section::load', { sectionId: section.id });

    resolve(true);
  });
}

// Refresh the HTML of any text input elements, no matter if it belongs to a section
export function updateSectionText(_window, section, blockId, settingId, value) {
  return new Promise((resolve, reject) => {
    var dataValue = `section-${section.id}`;

    if (blockId)
      dataValue = `${dataValue}-block.${blockId}.${settingId}`;
    else
      dataValue = `${dataValue}.${settingId}`;

    var $elem = $(_window.document)
      .find(`[data-locomotive-editor-setting='${dataValue}']`)
      .html(value);

    if ($elem.size() > 0)
      resolve(true);
    else
      reject();
  });
}

// Append a new section to the dropzone container. If another previewed section
// exists, it will be removed first.
export function previewSection(_window, html, section, previousSection) {
  return new Promise(resolve => {
    // remove the previous previewed section (if existing)
    if (previousSection) {
      const $previous = findSection(_window, previousSection.id);
      sendEvent($previous[0], 'section::unload', { sectionId: previousSection.id });
      $previous.remove();
    }

    // append the new one
    const $elem = $(html);
    $(_window.document).find('.locomotive-sections').append($elem)
    sendEvent($elem[0], 'section::load', { sectionId: section.id });

    resolve(true);
  });
}

export function moveSection(_window, section, targetSection, direction) {
  return new Promise(resolve => {
    const $elem   = findSection(_window, section.id);
    const $pivot  = findSection(_window, targetSection.id);

    if (direction === 'before')
      $elem.insertBefore($pivot);
    else
      $elem.insertAfter($pivot);

    sendEvent($elem[0], 'section::reorder', { sectionId: section.id });

    resolve(true);
  });
}

export function removeSection(_window, section) {
  return new Promise(resolve => {
    const $elem = findSection(_window, section.id);
    sendEvent($elem[0], 'section::unload', { sectionId: section.id });
    $elem.remove();

    resolve(true);
  });
}

export function selectSection(_window, section, blockId) {
  return pokeSection(_window, 'select', section.id, blockId);
}

export function deselectSection(_window, section, blockId) {
  return pokeSection(_window, 'deselect', section.id, blockId);
}
