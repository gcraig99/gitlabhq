<script>
import { GlSafeHtmlDirective as SafeHtml, GlLink } from '@gitlab/ui';
import { s__, n__ } from '~/locale';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  name: 'MRWidgetRelatedLinks',
  directives: {
    SafeHtml,
  },
  components: {
    GlLink,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    relatedLinks: {
      type: Object,
      required: true,
      default: () => ({}),
    },
    state: {
      type: String,
      required: false,
      default: '',
    },
    showAssignToMe: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    closesText() {
      if (this.state === 'merged') {
        return s__('mrWidget|Closed');
      }
      if (this.state === 'closed') {
        return s__('mrWidget|Did not close');
      }

      return n__('mrWidget|Closes issue', 'mrWidget|Closes issues', this.relatedLinks.closingCount);
    },
    assignIssueText() {
      if (this.relatedLinks.unassignedCount > 1) {
        return s__('mrWidget|Assign yourself to these issues');
      }
      return s__('mrWidget|Assign yourself to this issue');
    },
    shouldShowAssignToMeLink() {
      return (
        this.relatedLinks.unassignedCount && this.relatedLinks.assignToMe && this.showAssignToMe
      );
    },
  },
};
</script>
<template>
  <section>
    <p
      v-if="relatedLinks.closing"
      :class="{ 'gl-display-inline gl-m-0': glFeatures.restructuredMrWidget }"
    >
      {{ closesText }}
      <span v-safe-html="relatedLinks.closing"></span>
    </p>
    <p
      v-if="relatedLinks.mentioned"
      :class="{ 'gl-display-inline gl-m-0': glFeatures.restructuredMrWidget }"
    >
      <span v-if="relatedLinks.closing && glFeatures.restructuredMrWidget">&middot;</span>
      {{ n__('mrWidget|Mentions issue', 'mrWidget|Mentions issues', relatedLinks.mentionedCount) }}
      <span v-safe-html="relatedLinks.mentioned"></span>
    </p>
    <p
      v-if="shouldShowAssignToMeLink"
      :class="{ 'gl-display-inline gl-m-0': glFeatures.restructuredMrWidget }"
    >
      <span>
        <gl-link rel="nofollow" data-method="post" :href="relatedLinks.assignToMe">{{
          assignIssueText
        }}</gl-link>
      </span>
    </p>
  </section>
</template>
