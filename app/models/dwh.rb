require 'mondrian-olap'
class Dwh
@schema = Mondrian::OLAP::Schema.define do
	cube 'Sales' do
		table 'sales_facts'
		dimension 'Customer', :foreign_key => 'customer_id' do
			hierarchy :has_all => true, :primary_key => 'id' do
				table 'customer_dimension'
				level 'Name', :column => 'name', :unique_members => false
			end	
		end
		dimension 'Product', :foreign_key => 'product_id' do
			hierarchy :has_all => true, :primary_key_table => 'product_dimension', :primary_key => 'id' do
				join :left_key => 'product_level_id', :right_key => 'product_level_id' do
					table 'product_dimension'
					table 'product_levels'
				end
					level 'Type', :table => 'product_levels', :column => 'product_type', :unique_members => true
					level 'Category', :table => 'product_levels', :column => 'product_category', :unique_members => true
					level 'Subcategory', :table => 'product_levels', :column => 'product_subcategory', :unique_members => true
					level 'Name', :table => 'product_dimension', :column => 'name', :unique_members => true
			end			
		end

		measure 'Revenues', :column => 'sale_price', :aggregator => 'sum'
		measure 'Product Sales', :column => 'qty', :aggregator => 'sum'


	end
end

def self.schema; @schema; end

  params = ActiveRecord::Base.configurations[Rails.env].symbolize_keys
  @olap = Mondrian::OLAP::Connection.create(
	:driver => params[:adapter] == 'oracle_enhanced' ? 'oracle' : params[:adapter],
	:host => params[:host],
	:database => params[:database],
	:username => params[:username],
	:password => params[:password],
  	:schema => @schema
  )

  def self.olap; @olap; end
end


