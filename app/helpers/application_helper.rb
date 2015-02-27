module ApplicationHelper

  def flash_to_alert(key)
    {'alert' => 'warning', 'notice' => 'info'}[key] || 'default'
  end
end
