Spree::Core::Engine.routes.draw do
  # Add your extension routes here
	resources :orders do
		resource :checkout, controller: 'checkout' do
			member do
				get :directebanking_cancel
				get :directebanking_return
			end
		end
	end
end
