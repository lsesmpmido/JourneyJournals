# frozen_string_literal: true

module ApplicationHelper
  def i18n_pluralize(word)
    I18n.locale == :ja ? word : word.pluralize
  end

  def i18n_error_count(count)
    I18n.locale == :ja ? "#{count}件の#{t('views.common.error')}" : pluralize(count, t('views.common.error'))
  end
end
