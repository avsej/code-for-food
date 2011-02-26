require 'spec_helper'

describe Order do
  describe "validation" do
    it "valid" do
      Order.make.should be_valid
    end

    it "not valid if user is blank" do
      Order.make(:user => nil).should_not be_valid
    end

    it "not valid if menu is blank" do
      Order.make(:menu => nil).should_not be_valid
    end
  end

  describe "menu_items" do
    let(:menu) do
      Menu.make!.tap do |menu|
        3.times { menu.dishes << Dish.make! }
      end
    end
    let(:order) { Order.make :menu => menu }

    it "generates 3 menu items" do
      order.menu_items.should have(3).items
    end

    it "generates menu item for each dish" do
      menu.dishes.each do |dish|
        order.menu_items.map(&:dish_id).should include(dish.id)
      end
    end
    describe " accepts nested attributes for menu_items" do
      let(:attrs_for_first_dish) { { :dish_id => menu.dishes.first.id, :quantity => 1, :is_ordered => '1'} }

      it "builds one order_item" do
        order.menu_items_attributes = { "0" => attrs_for_first_dish }
        order.order_items.should have(1).item
      end

      it "builds none order_items" do
        order.menu_items_attributes = { "0" => attrs_for_first_dish.merge(:is_ordered => '0') }
        order.order_items.should have(0).item
      end
    end
  end
end
