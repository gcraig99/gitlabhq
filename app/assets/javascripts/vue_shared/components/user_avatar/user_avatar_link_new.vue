<script>
/* This is a re-usable vue component for rendering a user avatar wrapped in
  a clickable link (likely to the user's profile). The link, image, and
  tooltip can be configured by props passed to this component.

  Sample configuration:

  <user-avatar-link
    :link-href="userProfileUrl"
    :img-src="userAvatarSrc"
    :img-alt="tooltipText"
    :img-size="20"
    :tooltip-text="tooltipText"
    :tooltip-placement="top"
    :username="username"
  />

*/

import { GlAvatarLink, GlTooltipDirective } from '@gitlab/ui';
import UserAvatarImage from './user_avatar_image.vue';

export default {
  name: 'UserAvatarLinkNew',
  components: {
    UserAvatarImage,
    GlAvatarLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    lazy: {
      type: Boolean,
      required: false,
      default: false,
    },
    linkHref: {
      type: String,
      required: false,
      default: '',
    },
    imgSrc: {
      type: String,
      required: false,
      default: '',
    },
    imgAlt: {
      type: String,
      required: false,
      default: '',
    },
    imgCssClasses: {
      type: String,
      required: false,
      default: '',
    },
    imgSize: {
      type: Number,
      required: false,
      default: 20,
    },
    tooltipText: {
      type: String,
      required: false,
      default: '',
    },
    tooltipPlacement: {
      type: String,
      required: false,
      default: 'top',
    },
    username: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    shouldShowUsername() {
      return this.username.length > 0;
    },
    avatarTooltipText() {
      return this.shouldShowUsername ? '' : this.tooltipText;
    },
  },
};
</script>

<template>
  <gl-avatar-link :href="linkHref" class="user-avatar-link">
    <user-avatar-image
      :img-src="imgSrc"
      :img-alt="imgAlt"
      :css-classes="imgCssClasses"
      :size="imgSize"
      :tooltip-text="avatarTooltipText"
      :tooltip-placement="tooltipPlacement"
      :lazy="lazy"
    >
      <slot></slot>
    </user-avatar-image>

    <span
      v-if="shouldShowUsername"
      v-gl-tooltip
      :title="tooltipText"
      :tooltip-placement="tooltipPlacement"
      class="gl-ml-3"
      data-testid="user-avatar-link-username"
    >
      {{ username }}
    </span>

    <slot name="avatar-badge"></slot>
  </gl-avatar-link>
</template>
