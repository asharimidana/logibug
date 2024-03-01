Rails.application.routes.draw do
  # get 'notifications/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    get 'v1/report'
    namespace :v1 do
      # get 'notifications/index'
      post '/versions/clone/:id', to: 'versions#copy'
      resources :versions
      resources :scenarios
      get '/achieve', to: 'achievement#achieve'
      resources :test_cases
      
      get 'users/activate', to: 'users#email_activation'
      get 'cek', to:'users#cek'
      post 'login/', to: 'sessions#login'
      post 'logout/', to: 'sessions#logout'
      get "users?q=", to: "searchs#search"
      resources :users, only: [:index, :destroy, :update, :create]

      resources :profiles, only: [:index]
      put '/profiles', to: 'profiles#update'

      post 'token/', to: 'get_access_token#token'
      get 'members/join/', to: 'members#invite_activation'
      resources :members 
      post '/result', to: 'result#create'
      resources :results

      get 'projects/search?query=', to: 'projects#search'
      resources :projects
      get 'automatic/run/:id/:req_id', to: 'automatic#run_request'
      resources :automatic
      
      resources :roles

      get 'notifications/mark_as_read', to: 'notifications#mark_as_read'
      get 'notifications/mark_read_all', to: 'notifications#mark_all_read'
      resources :notifications, only: [:index]

      post '/upload_json', to: 'api#upload_json'
      get '/read_data/:id', to: 'api#read_data'

      get 'password/activate', to: 'password#password_activation'
      post '/password/forgot', to: 'password#forgot_password'
      post '/password/reset', to: 'password#reset_password'
      resources :report , only: [:show]

      post '/ai', to: 'ai#run_ai'
    end
  end
end

