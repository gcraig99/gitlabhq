<script>
import { GlToggle, GlSprintf, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';
import SettingsBlock from '~/vue_shared/components/settings/settings_block.vue';
import SettingsTitles from '~/packages_and_registries/settings/group/components/settings_titles.vue';
import updateDependencyProxySettings from '~/packages_and_registries/settings/group/graphql/mutations/update_dependency_proxy_settings.mutation.graphql';
import updateDependencyProxyImageTtlGroupPolicy from '~/packages_and_registries/settings/group/graphql/mutations/update_dependency_proxy_image_ttl_group_policy.mutation.graphql';
import { updateGroupPackageSettings } from '~/packages_and_registries/settings/group/graphql/utils/cache_update';
import {
  updateGroupDependencyProxySettingsOptimisticResponse,
  updateDependencyProxyImageTtlGroupPolicyOptimisticResponse,
} from '~/packages_and_registries/settings/group/graphql/utils/optimistic_responses';

import {
  DEPENDENCY_PROXY_HEADER,
  DEPENDENCY_PROXY_SETTINGS_DESCRIPTION,
  DEPENDENCY_PROXY_DOCS_PATH,
} from '~/packages_and_registries/settings/group/constants';

export default {
  name: 'DependencyProxySettings',
  components: {
    GlToggle,
    GlSprintf,
    GlLink,
    SettingsBlock,
    SettingsTitles,
  },
  i18n: {
    DEPENDENCY_PROXY_HEADER,
    DEPENDENCY_PROXY_SETTINGS_DESCRIPTION,
    enabledProxyLabel: s__('DependencyProxy|Enable Dependency Proxy'),
    enabledProxyHelpText: s__(
      'DependencyProxy|To see the image prefix and what is in the cache, visit the %{linkStart}Dependency Proxy%{linkEnd}',
    ),
    storageSettingsTitle: s__('DependencyProxy|Storage settings'),
    ttlPolicyEnabledLabel: s__('DependencyProxy|Clear the Dependency Proxy cache automatically'),
    ttlPolicyEnabledHelpText: s__(
      'DependencyProxy|When enabled, images older than 90 days will be removed from the cache.',
    ),
  },
  links: {
    DEPENDENCY_PROXY_DOCS_PATH,
  },
  inject: ['defaultExpanded', 'groupPath', 'groupDependencyProxyPath'],
  props: {
    dependencyProxySettings: {
      type: Object,
      required: true,
    },
    dependencyProxyImageTtlPolicy: {
      type: Object,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    enabled: {
      get() {
        return this.dependencyProxySettings.enabled;
      },
      set(enabled) {
        this.updateSettings({ enabled });
      },
    },
    ttlEnabled: {
      get() {
        return this.dependencyProxyImageTtlPolicy.enabled;
      },
      set(enabled) {
        const payload = {
          enabled,
          ttl: 90, // hardocded TTL for the MVC version
        };
        this.updateDependencyProxyImageTtlGroupPolicy(payload);
      },
    },
    helpText() {
      return this.enabled ? this.$options.i18n.enabledProxyHelpText : '';
    },
  },
  methods: {
    mutationVariables(payload) {
      return {
        input: {
          groupPath: this.groupPath,
          ...payload,
        },
      };
    },
    async executeMutation(config, resource) {
      try {
        const { data } = await this.$apollo.mutate(config);
        if (data[resource]?.errors.length > 0) {
          throw new Error();
        } else {
          this.$emit('success');
        }
      } catch {
        this.$emit('error');
      }
    },
    async updateSettings(payload) {
      const apolloConfig = {
        mutation: updateDependencyProxySettings,
        variables: this.mutationVariables(payload),
        update: updateGroupPackageSettings(this.groupPath),
        optimisticResponse: updateGroupDependencyProxySettingsOptimisticResponse({
          ...this.dependencyProxySettings,
          ...payload,
        }),
      };

      this.executeMutation(apolloConfig, 'updateDependencyProxySettings');
    },
    async updateDependencyProxyImageTtlGroupPolicy(payload) {
      const apolloConfig = {
        mutation: updateDependencyProxyImageTtlGroupPolicy,
        variables: this.mutationVariables(payload),
        update: updateGroupPackageSettings(this.groupPath),
        optimisticResponse: updateDependencyProxyImageTtlGroupPolicyOptimisticResponse({
          ...this.dependencyProxyImageTtlPolicy,
          ...payload,
        }),
      };

      this.executeMutation(apolloConfig, 'updateDependencyProxyImageTtlGroupPolicy');
    },
  },
};
</script>

<template>
  <settings-block
    :default-expanded="defaultExpanded"
    data-qa-selector="dependency_proxy_settings_content"
  >
    <template #title> {{ $options.i18n.DEPENDENCY_PROXY_HEADER }} </template>
    <template #description>
      <span data-testid="description">
        <gl-sprintf :message="$options.i18n.DEPENDENCY_PROXY_SETTINGS_DESCRIPTION">
          <template #docLink="{ content }">
            <gl-link
              data-testid="description-link"
              :href="$options.links.DEPENDENCY_PROXY_DOCS_PATH"
              >{{ content }}</gl-link
            >
          </template>
        </gl-sprintf>
      </span>
    </template>
    <template #default>
      <div>
        <gl-toggle
          v-model="enabled"
          :disabled="isLoading"
          :label="$options.i18n.enabledProxyLabel"
          :help="helpText"
          data-qa-selector="dependency_proxy_setting_toggle"
          data-testid="dependency-proxy-setting-toggle"
        >
          <template #help>
            <span class="gl-overflow-break-word gl-max-w-100vw gl-display-inline-block">
              <gl-sprintf :message="$options.i18n.enabledProxyHelpText">
                <template #link="{ content }">
                  <gl-link data-testid="toggle-help-link" :href="groupDependencyProxyPath">{{
                    content
                  }}</gl-link>
                </template>
              </gl-sprintf>
            </span>
          </template>
        </gl-toggle>

        <settings-titles :title="$options.i18n.storageSettingsTitle" class="gl-my-6" />
        <gl-toggle
          v-model="ttlEnabled"
          :disabled="isLoading"
          :label="$options.i18n.ttlPolicyEnabledLabel"
          :help="$options.i18n.ttlPolicyEnabledHelpText"
          data-testid="dependency-proxy-ttl-policies-toggle"
        />
      </div>
    </template>
  </settings-block>
</template>
