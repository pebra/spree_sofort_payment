Spree::CheckoutController.class_eval do
	before_filter :redirect_to_payment_network_if_needed, only: [:update]
	skip_before_filter :load_order, only: [:payment_network_callback]
	skip_before_filter :verify_authenticy_token, only: [:payment_network_callback]

	def redirect_to_payment_network_if_needed
		return unless (params[:state] == "payment")
		#1return unless params[:order][:payment_attributes]

		payment_method =  Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
		return unless payment_method.kind_of?(Spree::BillingIntegration::Directebanking)

		update_params = object_params.dup
		update_params.delete(:payments_attributes)
		if @order.update_attributes(update_params)
			fire_event('spree.checkout.update')
			render :edit and return unless apply_coupon_code
		end

		load_order
		if not @order.errors.empty?
			render :edit and return
		end

		redirect_to "#{payment_method.server_url}?user_id=#{payment_method.preferred_user_id}&project_id=#{payment_method.preferred_project_id}&amount=#{@order.total}&reason_1=#{@order.number}&user_variable_0=#{payment_method.id}&user_variable_1=#{@order.id}&hash=#{payment_method.hash_value(amount: @order.total, reason_1: @order.number, user_variable_1: @order.id)}"

		#confirmation_step_present = @order.payment.payment_method && @order.payment.payment_method.payment_profiles_supported?
		#if !confirmation_step_present && params[:state] == "payment"
		#	return unless params[:order][:payments_attributes]
		#	if params[:order][:coupon_code]
		#		@order.update_attributes(object_params)
		#		fire_event('spree.checkout.coupon_code_added', coupon_code: @order.coupon_code)
		#	end
		#	load_order
		#	payment_method = Spree::PaymentMethod.find(params[:order][:payment_attributes].first[:payment_method_id])
		#elsif confirmation_step_present && params[:state] == "confirm"
		#	load_order
		#	payment_method = @order.payment_method
		#end

		#if !payment_method.nil? && payment_method.kind_of?(BillingIntegration::Directebanking)
		#end
	end

	def payment_network_callback
		@order = Spree::Order.find params[:order_id]

		if @order && params[:status] == 'success'
			gateway = Spree::PaymentMethod.find params[:payment_method_id]

			@order.payments.clear
			payment = @order.payments.create
			payment.start_processing
			payment.amount = @order.total
			payment.payment.payment_method = gateway
			payment.complete
			@order.save

			until @order.state == "complete"
				if @order.next!
					@order.update!
					state_callback[:after]
				end
			end

			#change me
			flash[:notice] = "ORDER SUCCESS"
			redirect_to completion_route
		else
			redirect_to checkout_state_path @order.state
		end
	end
end
