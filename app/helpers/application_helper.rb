module ApplicationHelper
  def title str
    content_for(:title_string) { str }
  end
end
