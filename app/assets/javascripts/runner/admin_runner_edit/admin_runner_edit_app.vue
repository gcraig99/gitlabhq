<script>
import { createAlert } from '~/flash';
import { TYPE_CI_RUNNER } from '~/graphql_shared/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import RunnerHeader from '../components/runner_header.vue';
import RunnerUpdateForm from '../components/runner_update_form.vue';
import { I18N_FETCH_ERROR } from '../constants';
import runnerQuery from '../graphql/details/runner.query.graphql';
import { captureException } from '../sentry_utils';

export default {
  name: 'AdminRunnerEditApp',
  components: {
    RunnerHeader,
    RunnerUpdateForm,
  },
  props: {
    runnerId: {
      type: String,
      required: true,
    },
    runnerUrl: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      runner: null,
    };
  },
  apollo: {
    runner: {
      query: runnerQuery,
      variables() {
        return {
          id: convertToGraphQLId(TYPE_CI_RUNNER, this.runnerId),
        };
      },
      error(error) {
        createAlert({ message: I18N_FETCH_ERROR });

        this.reportToSentry(error);
      },
    },
  },
  computed: {
    loading() {
      return this.$apollo.queries.runner.loading;
    },
  },
  errorCaptured(error) {
    this.reportToSentry(error);
  },
  methods: {
    reportToSentry(error) {
      captureException({ error, component: this.$options.name });
    },
  },
};
</script>
<template>
  <div>
    <runner-header v-if="runner" :runner="runner" />
    <runner-update-form
      :loading="loading"
      :runner="runner"
      :runner-url="runnerUrl"
      class="gl-my-5"
    />
  </div>
</template>
