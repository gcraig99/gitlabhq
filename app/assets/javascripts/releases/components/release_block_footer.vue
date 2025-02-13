<script>
import { GlTooltipDirective, GlLink, GlIcon } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  name: 'ReleaseBlockFooter',
  components: {
    GlIcon,
    GlLink,
    UserAvatarLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  props: {
    commit: {
      type: Object,
      required: false,
      default: null,
    },
    commitPath: {
      type: String,
      required: false,
      default: '',
    },
    tagName: {
      type: String,
      required: false,
      default: '',
    },
    tagPath: {
      type: String,
      required: false,
      default: '',
    },
    author: {
      type: Object,
      required: false,
      default: null,
    },
    releasedAt: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    releasedAtTimeAgo() {
      return this.timeFormatted(this.releasedAt);
    },
    userImageAltDescription() {
      return this.author && this.author.username
        ? sprintf(__("%{username}'s avatar"), { username: this.author.username })
        : null;
    },
    createdTime() {
      const now = new Date();
      const isFuture = now < new Date(this.releasedAt);
      return isFuture ? __('Will be created') : __('Created');
    },
  },
};
</script>
<template>
  <div>
    <div v-if="commit" class="float-left mr-3 d-flex align-items-center js-commit-info">
      <gl-icon ref="commitIcon" name="commit" class="mr-1" />
      <div v-gl-tooltip.bottom :title="commit.title">
        <gl-link v-if="commitPath" :href="commitPath">
          {{ commit.shortId }}
        </gl-link>
        <span v-else>{{ commit.shortId }}</span>
      </div>
    </div>

    <div v-if="tagName" class="float-left mr-3 d-flex align-items-center js-tag-info">
      <gl-icon name="tag" class="mr-1" />
      <div v-gl-tooltip.bottom :title="__('Tag')">
        <gl-link v-if="tagPath" :href="tagPath">
          {{ tagName }}
        </gl-link>
        <span v-else>{{ tagName }}</span>
      </div>
    </div>

    <div
      v-if="releasedAt || author"
      class="float-left d-flex align-items-center js-author-date-info"
    >
      <span class="text-secondary">{{ createdTime }}&nbsp;</span>
      <template v-if="releasedAt">
        <span
          v-gl-tooltip.bottom
          :title="tooltipTitle(releasedAt)"
          class="text-secondary flex-shrink-0"
        >
          {{ releasedAtTimeAgo }}&nbsp;
        </span>
      </template>

      <div v-if="author" class="d-flex">
        <span class="text-secondary">{{ __('by') }}&nbsp;</span>
        <user-avatar-link
          class="gl-my-n1"
          :link-href="author.webUrl"
          :img-src="author.avatarUrl"
          :img-alt="userImageAltDescription"
          :img-size="24"
          :tooltip-text="author.username"
          tooltip-placement="bottom"
        />
      </div>
    </div>
  </div>
</template>
