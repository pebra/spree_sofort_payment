class Spree::BillingIntegration::Directebanking < Spree::BillingIntegration
	preference :user_id, :string
	preference :project_id, :string
	preference :project_password, :string
	preference :notification_password, :string

	attr_accessible :preferred_user_id, :preferred_project_id, :preferred_project_password, :preferred_notification_password, :prefered_server

	def server_url
		"https://www.sofortueberweisung.de/payment/start"
	end

	def hash_value(options = {})
		data = ActiveSupport::OrderedHash.new
		data[:user_id] = preferred_user_id
		data[:project_id] = preferred_project_id
		data[:sender_holder] = ''
		data[:sender_account_number] = ''
		data[:sender_bank_code] = ''
		data[:sender_country_id] = ''
		data[:amount] = ''
		data[:currency_id] = 'EUR'
		data[:reason_1] = ''
		data[:reason_2] = ''
		data[:user_variable_0] = id
		data[:user_variable_1] = ''
		data[:user_variable_2] = ''
		data[:user_variable_3] = ''
		data[:user_variable_4] = ''
		data[:user_variable_5] = ''
		data[:project_password] = preferred_project_password
		data.merge!(options)

		puts data.values.join '|'

		Digest::SHA512.hexdigest(data.values.join('|'))
	end

	def provider_class
		ActiveMerchant::Billing::Integrations::Directebanking
	end
end
