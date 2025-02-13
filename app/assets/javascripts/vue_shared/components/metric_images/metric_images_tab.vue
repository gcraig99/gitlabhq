<script>
import { GlFormGroup, GlFormInput, GlLoadingIcon, GlModal, GlTab } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { __, s__ } from '~/locale';
import UploadDropzone from '~/vue_shared/components/upload_dropzone/upload_dropzone.vue';
import MetricImagesTable from '~/vue_shared/components/metric_images/metric_images_table.vue';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlLoadingIcon,
    GlModal,
    GlTab,
    MetricImagesTable,
    UploadDropzone,
  },
  inject: ['canUpdate', 'projectId', 'iid'],
  data() {
    return {
      currentFiles: [],
      modalVisible: false,
      modalUrl: '',
      modalUrlText: '',
    };
  },
  computed: {
    ...mapState(['metricImages', 'isLoadingMetricImages', 'isUploadingImage']),
    actionPrimaryProps() {
      return {
        text: this.$options.i18n.modalUpload,
        attributes: {
          loading: this.isUploadingImage,
          disabled: this.isUploadingImage,
          category: 'primary',
          variant: 'confirm',
        },
      };
    },
  },
  mounted() {
    this.setInitialData({ modelIid: this.iid, projectId: this.projectId });
    this.fetchImages();
  },
  methods: {
    ...mapActions(['fetchImages', 'uploadImage', 'setInitialData']),
    clearInputs() {
      this.modalVisible = false;
      this.modalUrl = '';
      this.modalUrlText = '';
      this.currentFile = false;
    },
    openMetricDialog(files) {
      this.modalVisible = true;
      this.currentFiles = files;
    },
    async onUpload() {
      try {
        await this.uploadImage({
          files: this.currentFiles,
          url: this.modalUrl,
          urlText: this.modalUrlText,
        });
        // Error case handled within action
      } finally {
        this.clearInputs();
      }
    },
  },
  i18n: {
    modalUpload: __('Upload'),
    modalCancel: __('Cancel'),
    modalTitle: s__('Incidents|Add image details'),
    modalDescription: s__(
      "Incidents|Add text or a link to display with your image. If you don't add either, the file name displays instead.",
    ),
    dropDescription: s__(
      'Incidents|Drop or %{linkStart}upload%{linkEnd} a metric screenshot to attach it to the incident',
    ),
  },
};
</script>

<template>
  <gl-tab :title="s__('Incident|Metrics')" data-testid="metrics-tab">
    <div v-if="isLoadingMetricImages">
      <gl-loading-icon class="gl-p-5" size="sm" />
    </div>
    <gl-modal
      modal-id="upload-metric-modal"
      size="sm"
      :action-primary="actionPrimaryProps"
      :action-cancel="{ text: $options.i18n.modalCancel }"
      :title="$options.i18n.modalTitle"
      :visible="modalVisible"
      @hidden="clearInputs"
      @primary.prevent="onUpload"
    >
      <p>{{ $options.i18n.modalDescription }}</p>
      <gl-form-group :label="__('Text (optional)')" label-for="upload-text-input">
        <gl-form-input id="upload-text-input" v-model="modalUrlText" />
      </gl-form-group>

      <gl-form-group
        :label="__('Link (optional)')"
        label-for="upload-url-input"
        :description="s__('Incidents|Must start with http or https')"
      >
        <gl-form-input id="upload-url-input" v-model="modalUrl" />
      </gl-form-group>
    </gl-modal>
    <metric-images-table v-for="metric in metricImages" :key="metric.id" v-bind="metric" />
    <upload-dropzone
      v-if="canUpdate"
      :drop-description-message="$options.i18n.dropDescription"
      @change="openMetricDialog"
    />
  </gl-tab>
</template>
