import React, { Component } from 'react';
import { EditorState, convertToRaw, ContentState, SelectionState } from 'draft-js';
import { Editor, defaultToolbar } from 'react-draft-wysiwyg';
import draftToHtml from 'draftjs-to-html';
import htmlToDraft from 'html-to-draftjs';


class TextInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    if (value === undefined) value = props.setting.default || '';

    //create new content with raw html
    const { contentBlocks, entityMap } = htmlToDraft(value);
    const contentState = ContentState.createFromBlockArray(contentBlocks, entityMap);
    var editorState = EditorState.createWithContent(contentState);

    var html = props.setting.html || false;

    const line_height =  20;
    var line_break = props.setting.line_break || false;

    var editorHeight = (props.setting.rows || 5) * line_height;

    this.state = {
      editorState,
      value,
      html,
      editorHeight,
      line_break
    };

    this.inputOnChangeSanitizer = this.inputOnChangeSanitizer.bind(this);
    this.editorOnChangeSanitizer = this.editorOnChangeSanitizer.bind(this);
  }

  formatLineBreak(text) {
    return text
      .replace(/<\/p>\n<p>/g, '<br>')
      .replace(/<p>/g, '')
      .replace(/<\/p>/g, '');
  }

  inputOnChangeSanitizer(event){
    if(event.target) {
      this.updateSectionValue(event.target.value);
    }
  }

  editorOnChangeSanitizer(editorState) {
    this.setState({editorState: editorState});
    let value = draftToHtml(convertToRaw(editorState.getCurrentContent()));

    if(this.state.line_break) value = this.formatLineBreak(value)

    this.updateSectionValue(value);
  };

  updateSectionValue(value) {
    this.setState({ value }, () => {
      this.props.onChange(this.props.setting.type, this.props.setting.id, value)
    });
  }

  render() {
    const { setting } = this.props;
    const { editorState } = this.state;
    if(this.state.html) {
      return (
        <div>
          <label>{setting.label}</label>
          <div style={{"height": `${this.state.editorHeight}px`, "overflow": "scroll"}} >
            <Editor
              editorState={editorState}
              wrapperClassName="draftjs-wrapper"
              editorClassName="draftjs-editor"
              toolbarClassName="draftjs-toolbar"
              toolbar={TextInput.mytoolbar}
              onEditorStateChange={this.editorOnChangeSanitizer}
            />
          </div>
        </div>
      )
    }else{
      return (
        <div className="editor-input editor-input-text">
          <label>{setting.label}</label>
          <br/>
          <input type="text" value={this.state.value} onChange={this.inputOnChangeSanitizer} />
        </div>
      )
    }
  }
}

TextInput.mytoolbar = {
  ...defaultToolbar,
  ...{
    options: ['inline', 'textAlign', 'list', 'link', 'image'/*, 'file', 'table', 'expend', 'raw'*/],
    inline: {
      options: ['bold', 'italic', 'underline', 'strikethrough']
    },
    textAlign: {
      options: ['left', 'center', 'right', 'justify']
    },
    list: {
      options: ['unordered', 'ordered']
    },
    // link: {
    // },
    // image: {
    // },
    // file: {
    //   options: ['']
    // },
    // table: {
    //   options: ['']
    // },
    // expend: {
    //   options: ['']
    // },
    // raw: {
    //   options: ['']
    // },
  }
};

export default TextInput;
