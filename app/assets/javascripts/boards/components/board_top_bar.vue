<script>
import { mapGetters } from 'vuex';
import BoardAddNewColumnTrigger from '~/boards/components/board_add_new_column_trigger.vue';
import BoardsSelector from 'ee_else_ce/boards/components/boards_selector.vue';
import IssueBoardFilteredSearch from 'ee_else_ce/boards/components/issue_board_filtered_search.vue';
import ConfigToggle from './config_toggle.vue';
import NewBoardButton from './new_board_button.vue';
import ToggleFocus from './toggle_focus.vue';

export default {
  components: {
    BoardAddNewColumnTrigger,
    BoardsSelector,
    IssueBoardFilteredSearch,
    ConfigToggle,
    NewBoardButton,
    ToggleFocus,
    ToggleLabels: () => import('ee_component/boards/components/toggle_labels.vue'),
    ToggleEpicsSwimlanes: () => import('ee_component/boards/components/toggle_epics_swimlanes.vue'),
    EpicBoardFilteredSearch: () =>
      import('ee_component/boards/components/epic_filtered_search.vue'),
  },
  inject: ['swimlanesFeatureAvailable', 'canAdminList', 'isSignedIn'],
  computed: {
    ...mapGetters(['isEpicBoard']),
  },
};
</script>

<template>
  <div class="issues-filters">
    <div
      class="issues-details-filters filtered-search-block gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row row-content-block second-block"
    >
      <div
        class="gl-display-flex gl-flex-direction-column gl-md-flex-direction-row gl-flex-grow-1 gl-lg-mb-0! mb-md-2 mb-sm-0 gl-w-full"
      >
        <boards-selector />
        <new-board-button />
        <epic-board-filtered-search v-if="isEpicBoard" />
        <issue-board-filtered-search v-else />
      </div>
      <div
        class="filter-dropdown-container gl-display-flex gl-flex-direction-column gl-md-flex-direction-row gl-align-items-flex-start"
      >
        <toggle-labels />
        <toggle-epics-swimlanes v-if="swimlanesFeatureAvailable && isSignedIn" />
        <config-toggle />
        <board-add-new-column-trigger v-if="canAdminList" />
        <toggle-focus />
      </div>
    </div>
  </div>
</template>
