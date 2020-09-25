# frozen_string_literal: true

module API
  class GenericPackages < Grape::API::Instance
    GENERIC_PACKAGES_REQUIREMENTS = {
      package_name: API::NO_SLASH_URL_PART_REGEX,
      file_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    before do
      require_packages_enabled!
      authenticate!

      require_generic_packages_available!
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      route_setting :authentication, job_token_allowed: true

      namespace ':id/packages/generic' do
        namespace ':package_name/*package_version/:file_name', requirements: GENERIC_PACKAGES_REQUIREMENTS do
          desc 'Workhorse authorize generic package file' do
            detail 'This feature was introduced in GitLab 13.5'
          end

          route_setting :authentication, job_token_allowed: true

          params do
            requires :package_name, type: String, desc: 'Package name'
            requires :package_version, type: String, desc: 'Package version', regexp: Gitlab::Regex.generic_package_version_regex
            requires :file_name, type: String, desc: 'Package file name', regexp: Gitlab::Regex.generic_package_file_name_regex, file_path: true
          end

          put 'authorize' do
            authorize_workhorse!(subject: project, maximum_size: project.actual_limits.generic_packages_max_file_size)
          end

          desc 'Upload package file' do
            detail 'This feature was introduced in GitLab 13.5'
          end

          params do
            requires :package_name, type: String, desc: 'Package name'
            requires :package_version, type: String, desc: 'Package version', regexp: Gitlab::Regex.generic_package_version_regex
            requires :file_name, type: String, desc: 'Package file name', regexp: Gitlab::Regex.generic_package_file_name_regex, file_path: true
            requires :file, type: ::API::Validations::Types::WorkhorseFile, desc: 'The package file to be published (generated by Multipart middleware)'
          end

          route_setting :authentication, job_token_allowed: true

          put do
            authorize_upload!(project)
            bad_request!('File is too large') if max_file_size_exceeded?

            track_event('push_package')

            create_package_file_params = declared_params.merge(build: current_authenticated_job)
            ::Packages::Generic::CreatePackageFileService
              .new(project, current_user, create_package_file_params)
              .execute

            created!
          rescue ObjectStorage::RemoteStoreError => e
            Gitlab::ErrorTracking.track_exception(e, extra: { file_name: params[:file_name], project_id: project.id })

            forbidden!
          end
        end
      end
    end

    helpers do
      include ::API::Helpers::PackagesHelpers
      include ::API::Helpers::Packages::BasicAuthHelpers

      def require_generic_packages_available!
        not_found! unless Feature.enabled?(:generic_packages, project)
      end

      def project
        authorized_user_project
      end

      def max_file_size_exceeded?
        project.actual_limits.exceeded?(:generic_packages_max_file_size, params[:file].size)
      end
    end
  end
end