<script>
import { GlButton, GlTooltipDirective as GlTooltip } from '@gitlab/ui';
import EditorStateObserver from './editor_state_observer.vue';

export default {
  components: {
    GlButton,
    EditorStateObserver,
  },
  directives: {
    GlTooltip,
  },
  inject: ['tiptapEditor'],
  props: {
    iconName: {
      type: String,
      required: true,
    },
    contentType: {
      type: String,
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    editorCommand: {
      type: String,
      required: false,
      default: '',
    },
    variant: {
      type: String,
      required: false,
      default: 'default',
    },
    category: {
      type: String,
      required: false,
      default: 'tertiary',
    },
    size: {
      type: String,
      required: false,
      default: 'medium',
    },
  },
  data() {
    return {
      isActive: null,
    };
  },
  methods: {
    updateActive({ editor }) {
      this.isActive = editor.isActive(this.contentType) && editor.isFocused;
    },
    execute() {
      const { contentType } = this;

      if (this.editorCommand) {
        this.tiptapEditor.chain()[this.editorCommand]().focus().run();
      }

      this.$emit('execute', { contentType });
    },
  },
};
</script>
<template>
  <editor-state-observer @transaction="updateActive">
    <gl-button
      v-gl-tooltip
      :variant="variant"
      :category="category"
      :size="size"
      :class="{ active: isActive }"
      :aria-label="label"
      :title="label"
      :icon="iconName"
      @click="execute"
    />
  </editor-state-observer>
</template>
