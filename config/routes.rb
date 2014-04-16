Caravan::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

post 'api/login' => 'api#login'
post 'api/create_user' => 'api#create_user'
post 'api/broadcast' => 'api#broadcast'
post 'api/get_follow_requests' => 'api#check_requesters'
post 'api/invitation_response' => 'api#invitation_response'
post 'api/stop_broadcast' => 'api#stop_broadcast'
post 'api/follow_request' => 'api#follow_request'
post 'api/check_permission' => 'api#check_permission'
post 'api/follow' => 'api#follow'
post 'api/follow_cancellation' => 'api#follow_cancellation'
post 'api/set_follower_position' => 'api#set_follower_position'
post 'api/get_follower_positions' => 'api#get_follower_positions'
post 'api/get_recently_followed' => 'api#get_recently_followed'

end
