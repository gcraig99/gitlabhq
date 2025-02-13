# frozen_string_literal: true

RSpec.shared_examples 'logs downstream pipeline creation' do
  def record_downstream_pipeline_logs
    logs = []
    allow(::Gitlab::AppLogger).to receive(:info) do |args|
      logs << args
    end

    yield

    logs.find { |log| log[:message] == "downstream pipeline created" }
  end

  it 'logs details' do
    pipeline = nil

    log_entry = record_downstream_pipeline_logs do
      pipeline = subject
    end

    expect(log_entry).to be_present
    expect(log_entry).to eq(
      message: "downstream pipeline created",
      class: described_class.name,
      root_pipeline_id: expected_root_pipeline.id,
      downstream_pipeline_id: pipeline.id,
      downstream_pipeline_relationship: expected_downstream_relationship,
      hierarchy_size: expected_hierarchy_size,
      root_pipeline_plan: expected_root_pipeline.project.actual_plan_name,
      root_pipeline_namespace_path: expected_root_pipeline.project.namespace.full_path,
      root_pipeline_project_path: expected_root_pipeline.project.full_path)
  end

  context 'when feature flag ci_log_downstream_pipeline_creation is disabled' do
    before do
      stub_feature_flags(ci_log_downstream_pipeline_creation: false)
    end

    it 'does not log the creation' do
      log_entry = record_downstream_pipeline_logs { subject }

      expect(log_entry).to be_nil
    end
  end
end
