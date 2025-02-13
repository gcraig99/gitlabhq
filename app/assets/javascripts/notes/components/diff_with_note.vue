<script>
import {
  GlDeprecatedSkeletonLoading as GlSkeletonLoading,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import DiffFileHeader from '~/diffs/components/diff_file_header.vue';
import ImageDiffOverlay from '~/diffs/components/image_diff_overlay.vue';
import { getDiffMode } from '~/diffs/store/utils';
import { diffViewerModes } from '~/ide/constants';
import DiffViewer from '~/vue_shared/components/diff_viewer/diff_viewer.vue';
import { isCollapsed } from '~/diffs/utils/diff_file';

const FIRST_CHAR_REGEX = /^(\+|-| )/;

export default {
  components: {
    DiffFileHeader,
    GlSkeletonLoading,
    DiffViewer,
    ImageDiffOverlay,
  },
  directives: {
    SafeHtml,
  },
  props: {
    discussion: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      error: false,
    };
  },
  computed: {
    ...mapState({
      projectPath: (state) => state.diffs.projectPath,
    }),
    diffMode() {
      return getDiffMode(this.discussion.diff_file);
    },
    diffViewerMode() {
      return this.discussion.diff_file.viewer.name;
    },
    isTextFile() {
      return this.diffViewerMode === diffViewerModes.text;
    },
    hasTruncatedDiffLines() {
      return (
        this.discussion.truncated_diff_lines && this.discussion.truncated_diff_lines.length !== 0
      );
    },
    isCollapsed() {
      return isCollapsed(this.discussion.diff_file);
    },
  },
  mounted() {
    if (this.isTextFile && !this.hasTruncatedDiffLines) {
      this.fetchDiff();
    }
  },
  methods: {
    ...mapActions(['fetchDiscussionDiffLines']),
    fetchDiff() {
      this.error = false;
      this.fetchDiscussionDiffLines(this.discussion)
        .then(this.highlight)
        .catch(() => {
          this.error = true;
        });
    },
    trimChar(line) {
      return line.replace(FIRST_CHAR_REGEX, '');
    },
  },
  userColorSchemeClass: window.gon.user_color_scheme,
};
</script>

<template>
  <div :class="{ 'text-file': isTextFile }" class="diff-file file-holder">
    <diff-file-header
      :discussion-path="discussion.discussion_path"
      :diff-file="discussion.diff_file"
      :can-current-user-fork="false"
      :expanded="!isCollapsed"
    />
    <div v-if="isTextFile" class="diff-content">
      <table class="code js-syntax-highlight" :class="$options.userColorSchemeClass">
        <template v-if="hasTruncatedDiffLines">
          <tr
            v-for="line in discussion.truncated_diff_lines"
            v-once
            :key="line.line_code"
            class="line_holder"
          >
            <td :class="line.type" class="diff-line-num old_line">{{ line.old_line }}</td>
            <td :class="line.type" class="diff-line-num new_line">{{ line.new_line }}</td>
            <td v-safe-html="trimChar(line.rich_text)" :class="line.type" class="line_content"></td>
          </tr>
        </template>
        <tr v-if="!hasTruncatedDiffLines" class="line_holder line-holder-placeholder">
          <td class="old_line diff-line-num"></td>
          <td class="new_line diff-line-num"></td>
          <td v-if="error" class="js-error-lazy-load-diff diff-loading-error-block">
            {{ __('Unable to load the diff') }}
            <button
              class="btn-link btn-link-retry gl-p-0 js-toggle-lazy-diff-retry-button"
              @click="fetchDiff"
            >
              {{ __('Try again') }}
            </button>
          </td>
          <td v-else class="line_content js-success-lazy-load">
            <span></span>
            <gl-skeleton-loading />
            <span></span>
          </td>
        </tr>
        <tr class="notes_holder">
          <td class="notes-content" colspan="3"><slot></slot></td>
        </tr>
      </table>
    </div>
    <div v-else>
      <diff-viewer
        :diff-file="discussion.diff_file"
        :diff-mode="diffMode"
        :diff-viewer-mode="diffViewerMode"
        :new-path="discussion.diff_file.new_path"
        :new-sha="discussion.diff_file.diff_refs.head_sha"
        :old-path="discussion.diff_file.old_path"
        :old-sha="discussion.diff_file.diff_refs.base_sha"
        :file-hash="discussion.diff_file.file_hash"
        :project-path="projectPath"
      >
        <template #image-overlay="{ renderedWidth, renderedHeight }">
          <image-diff-overlay
            v-if="renderedWidth"
            :rendered-width="renderedWidth"
            :rendered-height="renderedHeight"
            :discussions="discussion"
            :file-hash="discussion.diff_file.file_hash"
            :show-comment-icon="true"
            :should-toggle-discussion="false"
            badge-class="image-comment-badge gl-text-gray-500"
          />
        </template>
      </diff-viewer>
      <slot></slot>
    </div>
  </div>
</template>
