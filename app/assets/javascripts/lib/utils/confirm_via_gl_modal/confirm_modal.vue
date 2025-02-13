<script>
import { GlModal, GlSafeHtmlDirective } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  cancelAction: { text: __('Cancel') },
  directives: {
    SafeHtml: GlSafeHtmlDirective,
  },
  components: {
    GlModal,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: '',
    },
    primaryText: {
      type: String,
      required: false,
      default: __('OK'),
    },
    primaryVariant: {
      type: String,
      required: false,
      default: 'confirm',
    },
    secondaryText: {
      type: String,
      required: false,
      default: '',
    },
    secondaryVariant: {
      type: String,
      required: false,
      default: 'confirm',
    },
    modalHtmlMessage: {
      type: String,
      required: false,
      default: '',
    },
    hideCancel: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    primaryAction() {
      return {
        text: this.primaryText,
        attributes: {
          variant: this.primaryVariant,
          'data-qa-selector': 'confirm_ok_button',
        },
      };
    },
    secondaryAction() {
      if (!this.secondaryText) {
        return null;
      }

      return {
        text: this.secondaryText,
        attributes: {
          variant: this.secondaryVariant,
          category: 'secondary',
        },
      };
    },
    cancelAction() {
      return this.hideCancel ? null : this.$options.cancelAction;
    },
    shouldShowHeader() {
      return Boolean(this.title?.length);
    },
  },
  mounted() {
    this.$refs.modal.show();
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    size="sm"
    modal-id="confirmationModal"
    body-class="gl-display-flex"
    :title="title"
    :action-primary="primaryAction"
    :action-cancel="cancelAction"
    :action-secondary="secondaryAction"
    :hide-header="!shouldShowHeader"
    @primary="$emit('confirmed')"
    @hidden="$emit('closed')"
  >
    <div v-if="!modalHtmlMessage" class="gl-align-self-center"><slot></slot></div>
    <div v-else v-safe-html="modalHtmlMessage" class="gl-align-self-center"></div>
  </gl-modal>
</template>
