<script>
/* eslint-disable @gitlab/vue-require-i18n-strings */
import { GlPopover, GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import CiIcon from '~/vue_shared/components/ci_icon.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { mrStates, humanMRStates } from '../constants';
import query from '../queries/merge_request.query.graphql';

export default {
  // name: 'MRPopover' is a false positive: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/25
  name: 'MRPopover', // eslint-disable-line @gitlab/require-i18n-strings
  components: {
    GlPopover,
    GlSkeletonLoading,
    CiIcon,
  },
  mixins: [timeagoMixin],
  props: {
    target: {
      type: HTMLAnchorElement,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    mergeRequestIID: {
      type: String,
      required: true,
    },
    mergeRequestTitle: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      mergeRequest: {},
    };
  },
  computed: {
    detailedStatus() {
      return this.mergeRequest.headPipeline && this.mergeRequest.headPipeline.detailedStatus;
    },
    formattedTime() {
      return this.timeFormatted(this.mergeRequest.createdAt);
    },
    statusBoxClass() {
      switch (this.mergeRequest.state) {
        case mrStates.merged:
          return 'status-box-mr-merged';
        case mrStates.closed:
          return 'status-box-closed';
        default:
          return 'status-box-open';
      }
    },
    stateHumanName() {
      switch (this.mergeRequest.state) {
        case mrStates.merged:
          return humanMRStates.merged;
        case mrStates.closed:
          return humanMRStates.closed;
        default:
          return humanMRStates.open;
      }
    },
    title() {
      return this.mergeRequest?.title || this.mergeRequestTitle;
    },
    showDetails() {
      return Object.keys(this.mergeRequest).length > 0;
    },
  },
  apollo: {
    mergeRequest: {
      query,
      update: (data) => data.project.mergeRequest,
      variables() {
        const { projectPath, mergeRequestIID } = this;

        return {
          projectPath,
          mergeRequestIID,
        };
      },
    },
  },
};
</script>

<template>
  <gl-popover :target="target" boundary="viewport" placement="top" show>
    <div class="mr-popover">
      <div v-if="$apollo.queries.mergeRequest.loading">
        <gl-skeleton-loading :lines="1" class="animation-container-small mt-1" />
      </div>
      <div v-else-if="showDetails" class="d-flex align-items-center justify-content-between">
        <div class="d-inline-flex align-items-center">
          <div :class="`issuable-status-box status-box ${statusBoxClass}`">
            {{ stateHumanName }}
          </div>
          <span class="gl-text-secondary">Opened <time v-text="formattedTime"></time></span>
        </div>
        <ci-icon v-if="detailedStatus" :status="detailedStatus" />
      </div>
      <h5 v-if="!$apollo.queries.mergeRequest.loading" class="my-2">{{ title }}</h5>
      <!-- eslint-disable @gitlab/vue-require-i18n-strings -->
      <div class="gl-text-secondary">
        {{ `${projectPath}!${mergeRequestIID}` }}
      </div>
      <!-- eslint-enable @gitlab/vue-require-i18n-strings -->
    </div>
  </gl-popover>
</template>
