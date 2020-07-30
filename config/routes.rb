Rails.application.routes.draw do
  root :to => "web/posts#index"

  scope module: :web do
    resources :posts
  end
end
