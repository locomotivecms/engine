import React, { Component } from 'react';
import { bindAll } from 'lodash';
import { EditorState, convertToRaw, ContentState, SelectionState } from 'draft-js';
import { Editor, defaultToolbar } from 'react-draft-wysiwyg';
import draftToHtml from 'draftjs-to-html';
import htmlToDraft from 'html-to-draftjs';
import { formatLineBreak, stripHTML } from '../utils/misc';

// Components
import Link from '../components/draft/link.jsx';

const MIN_ROWS    = 8;
const LINE_HEIGHT = 20;

class RichTextInput extends Component {

  constructor(props) {
    super(props);

    var value = props.value;
    if (value === undefined || value === null) value = props.setting.default || '';

    this.state = {
      editorState: this.createEditorContent(value),
      value
    };

    bindAll(this, 'inputOnChangeSanitizer', 'editorOnChangeSanitizer');
  }

  componentDidMount() {
    const { setting }   = this.props;
    const editorElement = this.input.querySelector('.draftjs-editor');

    if (editorElement)
      editorElement.style.height = `${(setting.nb_rows || MIN_ROWS) * LINE_HEIGHT}px`;
  }

  createEditorContent(html) {
    const { contentBlocks, entityMap } = htmlToDraft(html);
    const contentState = ContentState.createFromBlockArray(contentBlocks, entityMap);
    return EditorState.createWithContent(contentState);
  }

  inputOnChangeSanitizer(event) {
    if (event.target)
      this.updateSectionValue(event.target.value);
  }

  editorOnChangeSanitizer(editorState) {
    this.setState({ editorState });

    var value = draftToHtml(convertToRaw(editorState.getCurrentContent()));

    if (this.props.setting.line_break)
      value = formatLineBreak(value);

    this.updateSectionValue(value);
  };

  updateSectionValue(value) {
    this.setState({ value }, () => {
      this.props.onChange(this.props.setting.type, this.props.setting.id, value)
    });
  }

  render() {
    const { setting, label } = this.props;

    return (
      <div className="editor-input editor-input-rich-text" ref={el => this.input = el}>
        <label className="editor-input--label">
          {label}
        </label>
        <div>
          <Editor
            editorState={this.state.editorState}
            wrapperClassName="draftjs-wrapper"
            editorClassName="draftjs-editor"
            toolbarClassName="draftjs-toolbar"
            toolbar={RichTextInput.mytoolbar(setting.line_break !== true)}
            onEditorStateChange={this.editorOnChangeSanitizer}
            stripPastedStyles={true}
          />
          <div className="editor-input-rich-text-counter">
            {stripHTML(this.state.value).length}
          </div>
        </div>
      </div>
    );
  }
}

RichTextInput.mytoolbar = extended => {
  const options = extended ?
    ['inline', 'textAlign', 'blockType', 'list', 'link'] :
    ['inline', 'link'];

  return Object.assign({
    options,
    link: { component: Link, showOpenOptionOnHover: false },
    inline: {
      options: ['bold', 'italic', 'underline', 'strikethrough']
    },
    textAlign: {
      options: ['left', 'center', 'right', 'justify']
    },
    list: {
      options: ['unordered', 'ordered']
  } }, defaultToolbar);
};

export default RichTextInput;
