# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::External::File::Project do
  let_it_be(:context_project) { create(:project) }
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }

  let(:context_user) { user }
  let(:parent_pipeline) { double(:parent_pipeline) }
  let(:context) { Gitlab::Ci::Config::External::Context.new(**context_params) }
  let(:project_file) { described_class.new(params, context) }
  let(:variables) { project.predefined_variables.to_runner_variables }

  let(:context_params) do
    {
      project: context_project,
      sha: '12345',
      user: context_user,
      parent_pipeline: parent_pipeline,
      variables: variables
    }
  end

  before do
    project.add_developer(user)

    allow_next_instance_of(Gitlab::Ci::Config::External::Context) do |instance|
      allow(instance).to receive(:check_execution_time!)
    end
  end

  describe '#matching?' do
    context 'when a file and project is specified' do
      let(:params) { { file: 'file.yml', project: 'project' } }

      it 'returns true' do
        expect(project_file).to be_matching
      end
    end

    context 'with only file is specified' do
      let(:params) { { file: 'file.yml' } }

      it 'returns false' do
        expect(project_file).not_to be_matching
      end
    end

    context 'with only project is specified' do
      let(:params) { { project: 'project' } }

      it 'returns false' do
        expect(project_file).not_to be_matching
      end
    end

    context 'with a missing local key' do
      let(:params) { {} }

      it 'returns false' do
        expect(project_file).not_to be_matching
      end
    end
  end

  describe '#valid?' do
    subject(:valid?) do
      project_file.validate!
      project_file.valid?
    end

    context 'when a valid path is used' do
      let(:params) do
        { project: project.full_path, file: '/file.yml' }
      end

      let(:root_ref_sha) { project.repository.root_ref_sha }

      before do
        stub_project_blob(root_ref_sha, '/file.yml') { 'image: image:1.0' }
      end

      it { is_expected.to be_truthy }

      context 'when user does not have permission to access file' do
        let(:context_user) { create(:user) }

        it 'returns false' do
          expect(valid?).to be_falsy
          expect(project_file.error_message).to include("Project `#{project.full_path}` not found or access denied!")
        end
      end
    end

    context 'when a valid path with custom ref is used' do
      let(:params) do
        { project: project.full_path, ref: 'master', file: '/file.yml' }
      end

      let(:ref_sha) { project.commit('master').sha }

      before do
        stub_project_blob(ref_sha, '/file.yml') { 'image: image:1.0' }
      end

      it { is_expected.to be_truthy }
    end

    context 'when an empty file is used' do
      let(:params) do
        { project: project.full_path, file: '/secret_file.yml' }
      end

      let(:variables) { Gitlab::Ci::Variables::Collection.new([{ 'key' => 'GITLAB_TOKEN', 'value' => 'secret_file', 'masked' => true }]) }
      let(:root_ref_sha) { project.repository.root_ref_sha }

      before do
        stub_project_blob(root_ref_sha, '/secret_file.yml') { '' }
      end

      it 'returns false' do
        expect(valid?).to be_falsy
        expect(project_file.error_message).to include("Project `#{project.full_path}` file `/xxxxxxxxxxx.yml` is empty!")
      end
    end

    context 'when non-existing ref is used' do
      let(:params) do
        { project: project.full_path, ref: 'I-Do-Not-Exist', file: '/file.yml' }
      end

      it 'returns false' do
        expect(valid?).to be_falsy
        expect(project_file.error_message).to include("Project `#{project.full_path}` reference `I-Do-Not-Exist` does not exist!")
      end
    end

    context 'when non-existing file is requested' do
      let(:variables) { Gitlab::Ci::Variables::Collection.new([{ 'key' => 'GITLAB_TOKEN', 'value' => 'secret-invalid-file', 'masked' => true }]) }

      let(:params) do
        { project: project.full_path, file: '/secret-invalid-file.yml' }
      end

      it 'returns false' do
        expect(valid?).to be_falsy
        expect(project_file.error_message).to include("Project `#{project.full_path}` file `/xxxxxxxxxxxxxxxxxxx.yml` does not exist!")
      end
    end

    context 'when file is not a yaml file' do
      let(:params) do
        { project: project.full_path, file: '/invalid-file' }
      end

      it 'returns false' do
        expect(valid?).to be_falsy
        expect(project_file.error_message).to include('Included file `/invalid-file` does not have YAML extension!')
      end
    end

    context 'when non-existing project is used with a masked variable' do
      let(:variables) do
        Gitlab::Ci::Variables::Collection.new([
          { key: 'VAR1', value: 'a_secret_variable_value', masked: true }
        ])
      end

      let(:params) do
        { project: 'a_secret_variable_value', file: '/file.yml' }
      end

      it 'returns false with masked project name' do
        expect(valid?).to be_falsy
        expect(project_file.error_message).to include("Project `xxxxxxxxxxxxxxxxxxxxxxx` not found or access denied!")
      end
    end
  end

  describe '#expand_context' do
    let(:params) { { file: 'file.yml', project: project.full_path, ref: 'master' } }

    subject { project_file.send(:expand_context_attrs) }

    it 'inherits user, and target project and sha' do
      is_expected.to include(
        user: user,
        project: project,
        sha: project.commit('master').id,
        parent_pipeline: parent_pipeline,
        variables: project.predefined_variables.to_runner_variables)
    end
  end

  describe '#metadata' do
    let(:params) do
      { project: project.full_path, file: '/file.yml' }
    end

    subject(:metadata) { project_file.metadata }

    it {
      is_expected.to eq(
        context_project: context_project.full_path,
        context_sha: '12345',
        type: :file,
        location: '/file.yml',
        extra: { project: project.full_path, ref: 'HEAD' }
      )
    }

    context 'when project name and ref include masked variables' do
      let(:variables) do
        Gitlab::Ci::Variables::Collection.new([
          { key: 'VAR1', value: 'a_secret_variable_value1', masked: true },
          { key: 'VAR2', value: 'a_secret_variable_value2', masked: true }
        ])
      end

      let(:params) { { project: 'a_secret_variable_value1', ref: 'a_secret_variable_value2', file: '/file.yml' } }

      it {
        is_expected.to eq(
          context_project: context_project.full_path,
          context_sha: '12345',
          type: :file,
          location: '/file.yml',
          extra: { project: 'xxxxxxxxxxxxxxxxxxxxxxxx', ref: 'xxxxxxxxxxxxxxxxxxxxxxxx' }
        )
      }
    end
  end

  private

  def stub_project_blob(ref, path)
    allow_next_instance_of(Repository) do |instance|
      allow(instance).to receive(:blob_data_at).with(ref, path) { yield }
    end
  end
end
