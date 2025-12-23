Rails.application.routes.draw do
  # This routes file only contains entries for the host app.
  # Engine initializers handle setting up their own subdomain and mounting their routes.

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
