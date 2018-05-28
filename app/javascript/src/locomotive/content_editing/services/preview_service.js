export function updateStaticSection(window, sectionType, html) {
  const domID   = `locomotive-section-${sectionType}`;

  $(window.document)
    .find(`#${domID}.locomotive-section`)
    .html(html);
}

export function updateStaticSectionText(window, sectionType, blockId, settingId, value) {
  var dataValue = `section-${sectionType}`;

  if (blockId)
    dataValue = `${dataValue}-block.${blockId}.${settingId}`;
  else
    dataValue = `${dataValue}.${settingId}`;

  $(window.document)
    .find(`[data-locomotive-editor-setting='${dataValue}']`)
    .html(value);
}
