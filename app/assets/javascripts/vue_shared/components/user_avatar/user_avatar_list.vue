<script>
import { GlButton } from '@gitlab/ui';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { sprintf, __ } from '~/locale';
import UserAvatarLink from './user_avatar_link.vue';

export default {
  components: {
    UserAvatarLink,
    GlButton,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    items: {
      type: Array,
      required: true,
    },
    breakpoint: {
      type: Number,
      required: false,
      default: 10,
    },
    imgSize: {
      type: Number,
      required: false,
      default: 20,
    },
    emptyText: {
      type: String,
      required: false,
      default: __('None'),
    },
  },
  data() {
    return {
      isExpanded: false,
    };
  },
  computed: {
    visibleItems() {
      if (!this.hasHiddenItems) {
        return this.items;
      }

      return this.items.slice(0, this.breakpoint);
    },
    hasHiddenItems() {
      return this.hasBreakpoint && !this.isExpanded && this.items.length > this.breakpoint;
    },
    hasBreakpoint() {
      return this.breakpoint > 0 && this.items.length > this.breakpoint;
    },
    expandText() {
      if (!this.hasHiddenItems) {
        return '';
      }

      const count = this.items.length - this.breakpoint;

      return sprintf(__('%{count} more'), { count });
    },
    imgCssClasses() {
      return this.glFeatures.glAvatarForAllUserAvatars ? 'gl-mr-3' : '';
    },
  },
  methods: {
    expand() {
      this.isExpanded = true;
    },
    collapse() {
      this.isExpanded = false;
    },
  },
};
</script>

<template>
  <div v-if="!items.length">{{ emptyText }}</div>
  <div v-else>
    <user-avatar-link
      v-for="item in visibleItems"
      :key="item.id"
      :link-href="item.web_url"
      :img-src="item.avatar_url"
      :img-alt="item.name"
      :tooltip-text="item.name"
      :img-size="imgSize"
      :img-css-classes="imgCssClasses"
    />
    <template v-if="hasBreakpoint">
      <gl-button v-if="hasHiddenItems" variant="link" @click="expand">
        {{ expandText }}
      </gl-button>
      <gl-button v-else variant="link" @click="collapse">
        {{ __('show less') }}
      </gl-button>
    </template>
  </div>
</template>
