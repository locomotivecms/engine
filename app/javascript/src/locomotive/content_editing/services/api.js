const requestOptions = (verb, data, headers) => {
  return {
    method:       verb,
    body:         JSON.stringify(data),
    credentials: 'same-origin',
    headers: Object.assign({
      'Content-Type':   'application/json',
      'X-CSRF-Token':   document.querySelector('meta[name="csrf-token"]').content
    }, headers || {})
  }
}

const put = (url, data, headers) => {
  return fetch(url, requestOptions('PUT', data, headers));
}

const jsonPut = (url, data, headers) => {
  return put(url, data, headers)
    .then((response) => { return response.json() })
    .then((data) => {
      if (data.errors) throw(data.errors);
      return data;
    })
}

export function saveContent(site, page) {
  return jsonPut(window.Locomotive.urls.save, {
    site: { sections_content: JSON.stringify(site.sectionsContent) },
    page: { sections_content: JSON.stringify(page.sectionsContent) }
  });
}

export function loadSectionHTML(sectionType, content) {
  return put(window.Locomotive.urls.preview,
    { section_content: content[sectionType] },
    { 'Locomotive-Section-Type': sectionType }
  ).then(response => { return response.text(); })
}
