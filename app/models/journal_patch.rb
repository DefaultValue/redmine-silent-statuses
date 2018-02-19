module JournalPatch
  def self.included(base)
    base.send(:include, JournalExtraMethods)

    base.class_eval do
      alias_method_chain  :send_notification, :silence
    end
  end

  module JournalExtraMethods
    def send_notification_with_silence
      has_issue_changed = (Setting.notified_events.include?('issue_updated') ||
          (Setting.notified_events.include?('issue_note_added') && notes.present?) ||
          (Setting.notified_events.include?('issue_status_updated') && new_status.present?) ||
          (Setting.notified_events.include?('issue_assigned_to_updated') && detail_for_attribute('assigned_to_id').present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && new_value_for('priority_id').present?)
      )

      if notify? && has_issue_changed
        has_issue_status_changed         = new_status.present?
        changed_to_silent_status         = new_status.present? && Setting.plugin_silent_statuses && Setting.plugin_silent_statuses.include?(new_status.name.parameterize.underscore)
        should_notify_additional_changes = Setting.plugin_silent_statuses && Setting.plugin_silent_statuses.include?('notify_additional_changes')

        if has_issue_status_changed && changed_to_silent_status && !should_notify_additional_changes
          return false
        end
        if has_issue_status_changed && changed_to_silent_status && should_notify_additional_changes
          Mailer.deliver_issue_edit(self)
          return false
        end
        unless changed_to_silent_status
          Mailer.deliver_issue_edit(self)
          return false
        end
      end
    end
  end
end

Journal.send(:include, JournalPatch)
