(->
  window.remote_file_to_base64 = (url, callback) ->
    xhr = new XMLHttpRequest()
    xhr.open('GET', url, true)
    xhr.responseType = 'blob'

    xhr.onload = (event) ->
      if this.status == 200
        blob = this.response

        reader = new window.FileReader()
        reader.readAsDataURL(blob)
        reader.onloadend = -> callback(reader.result)
      else
        callback(null)

    xhr.onerror = (event) -> callback(null)

    xhr.send()
)()
