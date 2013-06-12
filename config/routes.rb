Spree::Core::Engine.routes.draw do
  # Add your extension routes here
	match '/checkout/payment_network_callback' => 'checkout#payment_network_callback'
end
