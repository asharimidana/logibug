class Api::V1::ReportController < ApplicationController
  before_action :authenticate_request!, only: %i[show]
  before_action only: %i[show] do
    cek_version = Scenario.find_by_project_id(
      project_id = params[:id],
      user_id = @current_user.id
    )
    if cek_version.present?
      render json: { errors: 'Access denied' }, status: :forbidden if cek_version == 'dev'
    else
      render json: { errors: 'Access denied' }, status: :forbidden
    end
  end
  def show
    project = Project.find(params[:id])
    versions = project.versions.includes(:test_cases)

    report = {
      project_name: project.name,
      versions: versions.map do |version|
                  test_cases_count = version.test_cases.count
                  result_count = version.test_cases.joins(:result).count

                  percentage = calculate_percentage(result_count, test_cases_count)

                  {
                    version_name: version.name,
                    test_case_count: test_cases_count,
                    test_case_pass_count: version.test_cases.joins(:result).where(results: { status: 1 }).count,
                    test_case_fail_count: version.test_cases.joins(:result).where(results: { status: 0 }).count,
                    percentage:
                  }
                end
    }

    render json: { message: 'success', data: report }, status: :ok

    # rescue StandardError
    #     render json: { errors: 'Project not exist' }, status: 404
  end

  private

  def calculate_percentage(value, total)
    return 0 if total.zero?

    (value.to_f / total * 100).round(2)
  end
end
