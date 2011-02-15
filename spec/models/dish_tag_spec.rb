require 'spec_helper'

describe DishTag do
  it "valid" do
    DishTag.make.should be_valid
  end

  it "set default value attr value to 0" do
    DishTag.make.value.should eql(0)
  end

  it "not valid if name is blank" do
    DishTag.make(:name => nil).should_not be_valid
  end

  it "not valid if value set to not valid integer value" do
    DishTag.make(:value => 'abc').should_not be_valid
    DishTag.make(:value => 10.6).should_not be_valid 
  end

  describe "many-to-many relation with Dish" do
    let(:dish) { Dish.make! }
    let(:tag) { DishTag.make! }

    it "adds new dish to dish list" do
      expect { tag.dishes << dish }.to change(tag.dishes, :count).from(0).to(1)
    end

    it "don't add same dish twice" do
      expect { 2.times { tag.dishes << dish } }.to change(tag.dishes, :count).from(0).to(1)
    end
  end
end