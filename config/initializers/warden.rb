Warden::Strategies.add(:guest_user) do
  def valid?
    session[:guest_user_id].present?
  end

  def authenticate!
    u = User.where(id: session[:guest_user_id]).first
    success!(u) if u.present?
  end
end


