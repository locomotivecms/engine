import React, { Component } from 'react';
import { EditorState, convertToRaw, ContentState, SelectionState } from 'draft-js';
import { Editor, defaultToolbar } from 'react-draft-wysiwyg';
import draftToHtml from 'draftjs-to-html';
import htmlToDraft from 'html-to-draftjs';
import { formatLineBreak } from '../utils/misc';

const LINE_HEIGHT = 20;

class TextInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    if (value === undefined) value = props.setting.default || '';

    this.state = {
      editorState: this.createEditorContent(value),
      value
    };

    this.inputOnChangeSanitizer = this.inputOnChangeSanitizer.bind(this);
    this.editorOnChangeSanitizer = this.editorOnChangeSanitizer.bind(this);
  }

  createEditorContent(html){
    const { contentBlocks, entityMap } = htmlToDraft(html);
    const contentState = ContentState.createFromBlockArray(contentBlocks, entityMap);
    return EditorState.createWithContent(contentState);
  }

  getHeight(nbRows){
    var editorHeight = (nbRows || 5) * LINE_HEIGHT;
  }

  inputOnChangeSanitizer(event){
    if(event.target) {
      this.updateSectionValue(event.target.value);
    }
  }

  editorOnChangeSanitizer(editorState) {
    this.setState({ editorState: editorState });

    var value = draftToHtml(convertToRaw(editorState.getCurrentContent()));
    if (this.props.setting.line_break) value = formatLineBreak(value)
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
    return (
      <div className="editor-input editor-input-text">
        <label>{setting.label}</label>
          {setting.html ? (
            <div style={{"height": `${this.getHeight(setting.rows)}px`, "overflow": "scroll"}} >
              <Editor
                editorState={editorState}
                wrapperClassName="draftjs-wrapper"
                editorClassName="draftjs-editor"
                toolbarClassName="draftjs-toolbar"
                toolbar={TextInput.mytoolbar}
                onEditorStateChange={this.editorOnChangeSanitizer}
              />
            </div>
          ) : (
            <div>
              <br/>
              <input type="text" value={this.state.value} onChange={this.inputOnChangeSanitizer} />
            </div>
          )}
      </div>
    );
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
