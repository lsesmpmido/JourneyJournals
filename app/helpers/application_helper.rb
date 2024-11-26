# frozen_string_literal: true

module ApplicationHelper
  def i18n_pluralize(word)
    I18n.locale == :ja ? word : word.pluralize
  end
end
