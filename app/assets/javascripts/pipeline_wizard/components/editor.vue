<script>
import { debounce } from 'lodash';
import { isDocument } from 'yaml';
import { CONTENT_UPDATE_DEBOUNCE } from '~/editor/constants';
import SourceEditor from '~/editor/source_editor';
import { YamlEditorExtension } from '~/editor/extensions/source_editor_yaml_ext';
import { SourceEditorExtension } from '~/editor/extensions/source_editor_extension_base';

export default {
  name: 'YamlEditor',
  props: {
    doc: {
      type: Object,
      required: true,
      validator: (d) => isDocument(d),
    },
    highlight: {
      type: [String, Array],
      required: false,
      default: null,
    },
    filename: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      editor: null,
      isUpdating: false,
      yamlEditorExtension: null,
    };
  },
  watch: {
    doc: {
      handler() {
        this.updateEditorContent();
      },
      deep: true,
    },
    highlight(v) {
      this.requestHighlight(v);
    },
  },
  mounted() {
    this.editor = new SourceEditor().createInstance({
      el: this.$el,
      blobPath: this.filename,
      language: 'yaml',
    });
    [, this.yamlEditorExtension] = this.editor.use([
      { definition: SourceEditorExtension },
      {
        definition: YamlEditorExtension,
        setupOptions: {
          highlightPath: this.highlight,
        },
      },
    ]);
    this.editor.onDidChangeModelContent(
      debounce(() => this.handleChange(), CONTENT_UPDATE_DEBOUNCE),
    );
    this.updateEditorContent();
    this.emitValue();
  },
  methods: {
    async updateEditorContent() {
      this.isUpdating = true;
      this.editor.setDoc(this.doc);
      this.isUpdating = false;
      this.requestHighlight(this.highlight);
    },
    handleChange() {
      this.emitValue();
      if (!this.isUpdating) {
        this.handleTouch();
      }
    },
    emitValue() {
      this.$emit('update:yaml', this.editor.getValue());
    },
    handleTouch() {
      this.$emit('touch');
    },
    requestHighlight(path) {
      this.editor.highlight(path, true);
    },
  },
};
</script>

<template>
  <div id="source-editor-yaml-editor"></div>
</template>
