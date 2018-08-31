import { decodeLinkResource, findParentElement, stopPropagation } from '../utils/misc';
import { startsWith } from 'lodash';

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
      $elem = $(_window.document).find(`#locomotive-section-${sectionId}`);
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

export function prepareIframe(_window) {
  _window.document.body.addEventListener('click', event => {
    var link = findParentElement('a', event.target);

    if (link) {
      const url       = link.getAttribute('href');
      const resource  = decodeLinkResource(url);

      // first case: link built by the RTE
      if (resource !== null && resource.type !== '_external')
        return;

      // second case: don't handle urls to an external site
      if (url[0] !== '/') {
        alert("This link cannot be opened inside the editor.");
        return stopPropagation(event);
      }
    }
  })
}

// Actions

export function updateSection(_window, section, html) {
  return new Promise(resolve => {
    var $elem = $(_window.document).find(`#locomotive-section-${section.id}`);

    sendEvent($elem[0], 'section::unload', { sectionId: section.id });
    $elem.replaceWith(html);

    // find the new element
    $elem = $(_window.document).find(`#locomotive-section-${section.id}`);
    sendEvent($elem[0], 'section::load', { sectionId: section.id });

    resolve(true);
  });
}

// Refresh the HTML of any text input elements, no matter if it belongs to a section
export function updateSectionText(_window, section, blockId, settingId, value) {
  return new Promise(resolve => {
    var dataValue = `section-${section.id}`;

    if (blockId)
      dataValue = `${dataValue}-block.${blockId}.${settingId}`;
    else
      dataValue = `${dataValue}.${settingId}`;

    $(_window.document)
      .find(`[data-locomotive-editor-setting='${dataValue}']`)
      .html(value);

    resolve(true);
  });
}

// Append a new section to the dropzone container. If another previewed section
// exists, it will be removed first.
export function previewSection(_window, html, section, previousSection) {
  return new Promise(resolve => {
    // remove the previous previewed section (if existing)
    if (previousSection) {
      const $previous = $(_window.document).find(`#locomotive-section-${previousSection.id}`);
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
    const $elem  = $(_window.document).find(`#locomotive-section-${section.id}`);
    const $pivot = $(_window.document).find(`#locomotive-section-${targetSection.id}`);

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
    const $elem = $(_window.document).find(`#locomotive-section-${section.id}`);
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
