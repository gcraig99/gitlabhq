# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::BackgroundMigrationsController, :enable_admin_mode do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe 'GET #show' do
    let(:migration) { create(:batched_background_migration) }

    it 'fetches the migration' do
      get admin_background_migration_path(migration)

      expect(response).to have_gitlab_http_status(:ok)
    end

    context 'when the migration does not exist' do
      let(:invalid_migration) { non_existing_record_id }

      it 'returns not found' do
        get admin_background_migration_path(invalid_migration)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'POST #retry' do
    let(:migration) { create(:batched_background_migration, :failed) }

    before do
      create(:batched_background_migration_job, :failed, batched_migration: migration, batch_size: 10, min_value: 6, max_value: 15, attempts: 3)

      allow_next_instance_of(Gitlab::BackgroundMigration::BatchingStrategies::PrimaryKeyBatchingStrategy) do |batch_class|
        allow(batch_class).to receive(:next_batch).with(
          anything,
          anything,
          batch_min_value: 6,
          batch_size: 5,
          job_arguments: migration.job_arguments
        ).and_return([6, 10])
      end
    end

    subject(:retry_migration) { post retry_admin_background_migration_path(migration) }

    it 'redirects the user to the admin migrations page' do
      retry_migration

      expect(response).to redirect_to(admin_background_migrations_path)
    end

    it 'retries the migration' do
      retry_migration

      expect(migration.reload.status_name).to be :active
    end

    context 'when the migration is not failed' do
      let(:migration) { create(:batched_background_migration, :paused) }

      it 'keeps the same migration status' do
        expect { retry_migration }.not_to change { migration.reload.status }
      end
    end
  end
end
