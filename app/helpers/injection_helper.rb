require 'open_food_network/enterprise_injection_data'

module InjectionHelper
  def inject_enterprises
    inject_json_ams "enterprises", Enterprise.activated.includes(:address).all, Api::EnterpriseSerializer, enterprise_injection_data
  end

  def inject_group_enterprises
    inject_json_ams "group_enterprises", @group.enterprises, Api::EnterpriseSerializer, enterprise_injection_data
  end

  def inject_current_hub
    inject_json_ams "currentHub", current_distributor, Api::EnterpriseSerializer, enterprise_injection_data
  end

  def inject_current_order
    inject_json_ams "currentOrder", current_order, Api::CurrentOrderSerializer, current_distributor: current_distributor, current_order_cycle: current_order_cycle
  end

  def inject_available_shipping_methods
    inject_json_ams "shippingMethods", available_shipping_methods,
      Api::ShippingMethodSerializer, current_order: current_order
  end

  def inject_available_payment_methods
    inject_json_ams "paymentMethods", current_order.available_payment_methods,
      Api::PaymentMethodSerializer
  end

  def inject_taxons
    inject_json_ams "taxons", Spree::Taxon.all, Api::TaxonSerializer
  end

  def inject_properties
    inject_json_ams "properties", Spree::Property.all, Api::IdNameSerializer
  end

  def inject_currency_config
    inject_json_ams "currencyConfig", {}, Api::CurrencyConfigSerializer
  end

  def inject_spree_api_key
    render partial: "json/injection_ams", locals: {name: 'spreeApiKey', json: "'#{@spree_api_key.to_s}'"}
  end

  def inject_available_countries
    inject_json_ams "availableCountries", available_countries, Api::CountrySerializer
  end

  def inject_enterprise_attributes
    render partial: "json/injection_ams", locals: {name: 'enterpriseAttributes', json: "#{@enterprise_attributes.to_json}"}
  end

  def inject_orders_by_distributor
    # Convert ActiveRecord::Relation to array for serialization
    # This query could maybe go in a model, or just serialize orders and handle the rest in JS
    data_array = Enterprise.includes(:distributed_orders).where(enterprises: {id: spree_current_user.enterprises_ordered_from }, spree_orders: {state: :complete, user_id: spree_current_user.id}).to_a
    data_array.sort!{|a,b| b.distributed_orders.length <=> a.distributed_orders.length}
    inject_json_ams "orders_by_distributor", data_array, Api::OrdersByDistributorSerializer
  end

  def inject_json(name, partial, opts = {})
    render partial: "json/injection", locals: {name: name, partial: partial}.merge(opts)
  end

  def inject_json_ams(name, data, serializer, opts = {})
    if data.is_a?(Array)
      json = ActiveModel::ArraySerializer.new(data, {each_serializer: serializer}.merge(opts)).to_json
    else
      json = serializer.new(data, opts).to_json
    end
    render partial: "json/injection_ams", locals: {name: name, json: json}
  end


  private

  def enterprise_injection_data
    @enterprise_injection_data ||= OpenFoodNetwork::EnterpriseInjectionData.new
    {data: @enterprise_injection_data}
  end

end
