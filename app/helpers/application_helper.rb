# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def hinted_text_field_tag(name, value = nil, hint = "Click and enter text", options={})
    value = value.nil? ? hint : value
    text_field_tag name, value, {:onclick => "if($(this).value == '#{hint}'){$(this).value = ''}", :onblur => "if($(this).value == ''){$(this).value = '#{hint}'}" }.update(options.stringify_keys)
  end

  def current_announcement
    @current_announcements ||= Announcement.current_announcements(session[:announcement_hide_time])
  end

  def sortable(search,column,title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column  == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:search => search,:sort => column, :direction => direction},{:class => css_class}
  end
end
