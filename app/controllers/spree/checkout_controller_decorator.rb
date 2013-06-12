module Spree
	CheckoutController.class_eval do
		before_filter :redirect_to_payment_network_if_needed, only: [:update]
		skip_before_filter :verify_authenticy_token, only: [:payment_network_callback]


		def directebanking_return
			

			if ["pending", "received"].include? params[:status]
				payment_method = PaymentMethod.find params[:payment_method_id]
				unless @order.payments.where(payment_method_id: payment_method.id).present?
					payment = @order.payments.create({	
																						amount: @order.total,
																						payment_method_id: payment_method.id,
																						without_protection: true
																					})
					payment.started_processing!
					payment.complete!
				end


				@order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)
				#until @order.state == "complete"
				#	binding.pry
				#	if @order.next!
				#		@order.update!
					session[:order_id] = nil
				#	end
				#end
					flash.notice = "ORDER SUCCESSFULL"

					redirect_to completion_route
			else
				redirect_to edit_order_path
			end
		end

		def directebanking_cancel
			flash.error = "ERROR"
			redirect_to edit_order_path (@order)
		end

		private
			def redirect_to_payment_network_if_needed
				return unless (params[:state] == "payment")
				payment_method =  Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
				return unless payment_method.kind_of?(Spree::BillingIntegration::Directebanking)
				load_order
				unless @order.errors.empty?
					render :edit and return
				end

				redirect_to "#{payment_method.server_url}?user_id=#{payment_method.preferred_user_id}&project_id=#{payment_method.preferred_project_id}&amount=#{@order.total}&reason_1=#{@order.number}&user_variable_0=#{payment_method.id}&user_variable_1=#{@order.id}&hash=#{payment_method.hash_value(amount: @order.total, reason_1: @order.number, user_variable_1: @order.id)}"
			end
	end
end
