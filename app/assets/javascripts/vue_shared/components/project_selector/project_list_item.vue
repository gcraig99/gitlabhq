<script>
import { GlButton, GlIcon, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { isString } from 'lodash';
import highlight from '~/lib/utils/highlight';
import { truncateNamespace } from '~/lib/utils/text_utility';
import ProjectAvatar from '~/vue_shared/components/project_avatar.vue';

export default {
  name: 'ProjectListItem',
  components: { GlIcon, ProjectAvatar, GlButton },
  directives: { SafeHtml },
  props: {
    project: {
      type: Object,
      required: true,
      validator: (p) =>
        (Number.isFinite(p.id) || isString(p.id)) &&
        isString(p.name) &&
        (isString(p.name_with_namespace) || isString(p.nameWithNamespace)),
    },
    selected: { type: Boolean, required: true },
    matcher: { type: String, required: false, default: '' },
  },
  computed: {
    projectAvatarUrl() {
      return this.project.avatar_url || this.project.avatarUrl;
    },
    projectNameWithNamespace() {
      return this.project.nameWithNamespace || this.project.name_with_namespace;
    },
    truncatedNamespace() {
      return truncateNamespace(this.projectNameWithNamespace);
    },
    highlightedProjectName() {
      return highlight(this.project.name, this.matcher);
    },
  },
  methods: {
    onClick() {
      this.$emit('click');
    },
  },
};
</script>
<template>
  <gl-button
    category="tertiary"
    class="gl-display-flex gl-align-items-center gl-justify-content-start! gl-mb-2 gl-w-full"
    @click="onClick"
  >
    <div
      class="gl-display-flex gl-align-items-center gl-flex-wrap project-namespace-name-container"
    >
      <gl-icon v-if="selected" class="js-selected-icon" name="mobile-issue-close" />
      <project-avatar
        :project-avatar-url="projectAvatarUrl"
        :project-name="projectNameWithNamespace"
        class="gl-mr-3"
      />
      <div
        v-if="truncatedNamespace"
        :title="projectNameWithNamespace"
        class="text-secondary text-truncate js-project-namespace"
      >
        {{ truncatedNamespace }}
        <span v-if="truncatedNamespace" class="text-secondary">/&nbsp;</span>
      </div>
      <div
        v-safe-html="highlightedProjectName"
        :title="project.name"
        class="js-project-name text-truncate"
      ></div>
    </div>
  </gl-button>
</template>
