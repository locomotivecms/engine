import { toInt } from '../utils/misc';
import { each } from 'lodash';

const requestOptions = (verb, data, headers) => {
  const _headers = Object.assign({
    'Content-Type':   'application/json',
    'X-CSRF-Token':   document.querySelector('meta[name="csrf-token"]').content
  }, headers);

  if (_headers['Content-Type'] === null)
    delete _headers['Content-Type'];

  var options = {
    method:       verb,
    credentials:  'same-origin',
    headers:      _headers
  }

  if (verb !== 'GET')
    options.body = data;

  return options;
}

const post = (url, data, headers) => {
  return fetch(url, requestOptions('POST', data, headers));
}

const put = (url, data, headers) => {
  return fetch(url, requestOptions('PUT', data, headers));
}

const jsonPut = (url, data, headers) => {
  return put(url, JSON.stringify(data), headers)
    .then((response) => { return response.json() })
    .then((data) => {
      if (data.errors) throw(data.errors);
      return data;
    })
}

const get = (url, query, headers) => {
  var url = new URL(url, window.location.origin);
  Object.keys(query || {}).forEach(key => url.searchParams.append(key, query[key]));
  return fetch(url.href, requestOptions('GET', null, headers));
}

const jsonGet = (url, query, headers) => {
  return get(url, query, headers)
    .then((response) => {
      const headers = response.headers;
      return response.json().then(json => { return { headers, json } });
    });
}

// CONTENT

export function saveContent(site, page) {
  return jsonPut(window.Locomotive.urls.save, {
    site: { sections_content: JSON.stringify(site.sectionsContent) },
    page: { sections_content: JSON.stringify(page.sectionsContent) }
  });
}

// SECTION

export function loadSectionHTML(sectionType, content) {
  return put(window.Locomotive.urls.preview,
    JSON.stringify({ section_content: content }),
    { 'Locomotive-Section-Type': sectionType }
  ).then(response => { return response.text(); })
}

// CONTENT ASSETS

export function uploadAssets(assets) {
  var form = new FormData();
  each(assets, asset => form.append('content_assets[][source]', asset))

  return post(window.Locomotive.urls.bulkAssetUpload, form, {
    'Content-Type': null
  }).then(response => response.json())
}

export function loadAssets(options) {
  return jsonGet(window.Locomotive.urls.assets, {
    page:     options.pagination.page || 1,
    per_page: options.pagination.perPage || 10
  })
  .then(response => {
    return {
      list:         response.json,
      pagination:   {
        page:         toInt(response.headers.get('x-current-page')),
        perPage:      toInt(response.headers.get('x-per-page')),
        totalPages:   toInt(response.headers.get('x-total-pages')),
        totalEntries: toInt(response.headers.get('x-total-entries'))
      }
    }
  });
}
