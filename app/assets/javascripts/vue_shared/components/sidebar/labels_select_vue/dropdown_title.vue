<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
  },
  props: {
    labelsSelectInProgress: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapState(['allowLabelEdit', 'labelsFetchInProgress']),
  },
  methods: {
    ...mapActions(['toggleDropdownContents']),
  },
};
</script>

<template>
  <div class="hide-collapsed gl-line-height-20 gl-mb-2 gl-text-gray-900 gl-font-weight-bold">
    {{ __('Labels') }}
    <template v-if="allowLabelEdit">
      <gl-loading-icon v-show="labelsSelectInProgress" size="sm" inline />
      <gl-button
        category="tertiary"
        size="small"
        class="float-right js-sidebar-dropdown-toggle gl-mr-n2"
        data-qa-selector="labels_edit_button"
        @click="toggleDropdownContents"
      >
        {{ __('Edit') }}
      </gl-button>
    </template>
  </div>
</template>
