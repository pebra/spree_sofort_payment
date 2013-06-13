SpreeSofortPayment
==================

CAUTION: Not ready for porduction, yet.

Set up your success link in your Sofort AG settings as following:
``` shell
http://your-shop-url.com/orders/-USER_VARIABLE_1-/checkout/directebanking_return?status=-STATUS-&payment_method_id=-USER_VARIABLE_0-&order_id=-USER_VARIABLE_1-
```

Installation
------------

Add spree_sofort_payment to your Gemfile:

```ruby
gem 'spree_sofort_payment'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_sofort_payment:install
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_sofort_payment/factories'
```

Copyright (c) 2013 [name of extension creator], released under the New BSD License
