<script>
import { isEmpty } from 'lodash';
import { GlButtonGroup } from '@gitlab/ui';
import getToolbarItemsQuery from '~/editor/graphql/get_items.query.graphql';
import { EDITOR_TOOLBAR_LEFT_GROUP, EDITOR_TOOLBAR_RIGHT_GROUP } from '~/editor/constants';
import SourceEditorToolbarButton from './source_editor_toolbar_button.vue';

export default {
  name: 'SourceEditorToolbar',
  components: {
    SourceEditorToolbarButton,
    GlButtonGroup,
  },
  data() {
    return {
      items: [],
    };
  },
  apollo: {
    items: {
      query: getToolbarItemsQuery,
      update(data) {
        return this.setDefaultGroup(data?.items?.nodes);
      },
    },
  },
  computed: {
    isVisible() {
      return this.items.length;
    },
  },
  methods: {
    setDefaultGroup(nodes = []) {
      return nodes.map((item) => {
        return {
          ...item,
          group:
            (this.$options.groups.includes(item.group) && item.group) || EDITOR_TOOLBAR_RIGHT_GROUP,
        };
      });
    },
    getGroupItems(group) {
      return this.items.filter((item) => item.group === group);
    },
    hasGroupItems(group) {
      return !isEmpty(this.getGroupItems(group));
    },
  },
  groups: [EDITOR_TOOLBAR_LEFT_GROUP, EDITOR_TOOLBAR_RIGHT_GROUP],
};
</script>
<template>
  <section
    v-if="isVisible"
    id="se-toolbar"
    class="gl-py-3 gl-px-5 gl-bg-white gl-border-t gl-border-b gl-display-flex gl-justify-content-space-between gl-align-items-center"
  >
    <template v-for="group in $options.groups">
      <gl-button-group v-if="hasGroupItems(group)" :key="group">
        <template v-for="item in getGroupItems(group)">
          <source-editor-toolbar-button
            :key="item.id"
            :button="item"
            @click="$emit('click', item)"
          />
        </template>
      </gl-button-group>
    </template>
  </section>
</template>
