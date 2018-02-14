module SilentStatusesSettingsHelper
  def redmine_silent_statuses_list_of_active_statuses
    allStatuses = IssueStatus.all.sorted
  end
end
