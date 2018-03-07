require_dependency '../../plugins/silent_statuses/app/models/journal_patch'

Redmine::Plugin.register :silent_statuses do
  name 'Silent Statuses plugin'
  author 'Default Value'
  description 'This plugin provides functionality to disable notifications regarding moving issue into certain statuses.'
  version '1.0'
  author_url 'http://default-value.com/'

  settings \
    :partial => 'settings/statuses_settings'
end

ActionDispatch::Reloader.to_prepare do
  SettingsHelper.send :include, SilentStatusesSettingsHelper
end
