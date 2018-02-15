module JournalPatch
  def self.included(base)
    base.send(:include, JournalExtraMethods)

    base.class_eval do
      alias_method_chain  :send_notification, :silence
    end
  end

  module JournalExtraMethods
    def send_notification_with_silence
      silent_mode = new_status.present? && Setting.plugin_silent_statuses.include?(new_status.name.parameterize.underscore)
      if !silent_mode && notify? && (Setting.notified_events.include?('issue_updated') ||
          (Setting.notified_events.include?('issue_note_added') && notes.present?) ||
          (Setting.notified_events.include?('issue_status_updated') && new_status.present?) ||
          (Setting.notified_events.include?('issue_assigned_to_updated') && detail_for_attribute('assigned_to_id').present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && new_value_for('priority_id').present?)
      )
        Mailer.deliver_issue_edit(self)
      end
    end
  end
end

Journal.send(:include, JournalPatch)
