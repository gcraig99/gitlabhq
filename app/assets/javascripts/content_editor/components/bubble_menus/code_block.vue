<script>
import {
  GlButton,
  GlButtonGroup,
  GlDropdown,
  GlDropdownItem,
  GlSearchBoxByType,
  GlTooltipDirective as GlTooltip,
} from '@gitlab/ui';
import { BubbleMenu } from '@tiptap/vue-2';
import { getParentByTagName } from '~/lib/utils/dom_utils';
import codeBlockLanguageLoader from '../../services/code_block_language_loader';
import CodeBlockHighlight from '../../extensions/code_block_highlight';
import Diagram from '../../extensions/diagram';
import Frontmatter from '../../extensions/frontmatter';
import EditorStateObserver from '../editor_state_observer.vue';

const CODE_BLOCK_NODE_TYPES = [CodeBlockHighlight.name, Diagram.name, Frontmatter.name];

export default {
  components: {
    BubbleMenu,
    GlButton,
    GlButtonGroup,
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
    EditorStateObserver,
  },
  directives: {
    GlTooltip,
  },
  inject: ['tiptapEditor'],
  data() {
    return {
      codeBlockType: undefined,
      selectedLanguage: {},
      filterTerm: '',
      filteredLanguages: [],
    };
  },
  watch: {
    filterTerm: {
      handler(val) {
        this.filteredLanguages = codeBlockLanguageLoader.filterLanguages(val);
      },
      immediate: true,
    },
  },
  methods: {
    shouldShow: ({ editor }) => {
      return CODE_BLOCK_NODE_TYPES.some((type) => editor.isActive(type));
    },

    updateSelectedLanguage() {
      this.codeBlockType = CODE_BLOCK_NODE_TYPES.find((type) => this.tiptapEditor.isActive(type));

      if (this.codeBlockType) {
        const { language } = this.tiptapEditor.getAttributes(this.codeBlockType);
        this.selectedLanguage = codeBlockLanguageLoader.findLanguageBySyntax(language);
      }
    },

    copyCodeBlockText() {
      const { view } = this.tiptapEditor;
      const { from } = this.tiptapEditor.state.selection;
      const node = getParentByTagName(view.domAtPos(from).node, 'pre');

      navigator.clipboard.writeText(node?.textContent || '');
    },

    async applySelectedLanguage(language) {
      this.selectedLanguage = language;

      await codeBlockLanguageLoader.loadLanguages([language.syntax]);

      this.tiptapEditor.commands.setCodeBlock({ language: this.selectedLanguage.syntax });
    },

    tippyOnBeforeUpdate(tippy, props) {
      if (props.getReferenceClientRect) {
        // eslint-disable-next-line no-param-reassign
        props.getReferenceClientRect = () => {
          const { view } = this.tiptapEditor;
          const { from } = this.tiptapEditor.state.selection;

          const node = getParentByTagName(view.domAtPos(from).node, 'pre');
          if (node) return node.getBoundingClientRect();

          return new DOMRect(-1000, -1000, 0, 0);
        };
      }
    },

    deleteCodeBlock() {
      this.tiptapEditor.chain().focus().deleteNode(this.codeBlockType).run();
    },
  },
};
</script>
<template>
  <bubble-menu
    data-testid="code-block-bubble-menu"
    class="gl-shadow gl-rounded-base gl-bg-white"
    :editor="tiptapEditor"
    plugin-key="bubbleMenuCodeBlock"
    :should-show="shouldShow"
    :tippy-options="{ onBeforeUpdate: tippyOnBeforeUpdate }"
  >
    <editor-state-observer @transaction="updateSelectedLanguage">
      <gl-button-group>
        <gl-dropdown
          category="tertiary"
          contenteditable="false"
          boundary="viewport"
          :text="selectedLanguage.label"
        >
          <template #header>
            <gl-search-box-by-type
              v-model="filterTerm"
              :clear-button-title="__('Clear')"
              :placeholder="__('Search')"
            />
          </template>

          <template #highlighted-items>
            <gl-dropdown-item :key="selectedLanguage.syntax" is-check-item :is-checked="true">
              {{ selectedLanguage.label }}
            </gl-dropdown-item>
          </template>

          <gl-dropdown-item
            v-for="language in filteredLanguages"
            v-show="selectedLanguage.syntax !== language.syntax"
            :key="language.syntax"
            @click="applySelectedLanguage(language)"
          >
            {{ language.label }}
          </gl-dropdown-item>
        </gl-dropdown>
        <gl-button
          v-gl-tooltip
          variant="default"
          category="tertiary"
          size="medium"
          data-testid="copy-code-block"
          :aria-label="__('Copy code')"
          :title="__('Copy code')"
          icon="copy-to-clipboard"
          @click="copyCodeBlockText"
        />
        <gl-button
          v-gl-tooltip
          variant="default"
          category="tertiary"
          size="medium"
          data-testid="delete-code-block"
          :aria-label="__('Delete code block')"
          :title="__('Delete code block')"
          icon="remove"
          @click="deleteCodeBlock"
        />
      </gl-button-group>
    </editor-state-observer>
  </bubble-menu>
</template>
