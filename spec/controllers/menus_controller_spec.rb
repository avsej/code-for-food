require 'spec_helper'

describe MenusController do
  render_views
  setup :activate_authlogic

  describe "GET new" do
    it "renders a \"new\" template" do
      get :new
      response.should render_template('new')
    end

    it "sets a menu date from params" do
      get :new, :date => '1999-03-05'
      assigns[:menu].date.should eql(Date.parse('1999-03-05'))
    end
  end

  describe "POST create" do
    context "when not logged in" do
      it "redirects to login page" do
        post :create, :menu => Menu.make.attributes
        response.should redirect_to(login_path)
      end
    end

    context "when logged in as admin" do
      before(:each) {UserSession.create(Administrator.make!)}

      it "creates a new menu" do
        expect { post :create, :menu => Menu.make.attributes }.to change(Menu, :count).by(1)
      end

      it "creates the dishes for menu" do
        post_attrs = Menu.make.attributes.merge :dishes_attributes => {0 => Dish.make(:menu => nil).attributes, 1 => Dish.make(:menu => nil).attributes}
        expect { post :create, :menu => post_attrs }.to change(Dish, :count).by(2)
      end

      it "redirects to \"show\" action" do
        post :create, :menu => Menu.make.attributes
        response.should be_redirect
      end

      it "renders a \"new\" template if menu not valid" do
        post :create
        assigns[:menu].should_not be_valid
        response.should render_template('new')
      end
    end
  end

  describe "GET show" do
    context "when not logged in" do
      it "redirects to login page" do
        post :create, :menu => Menu.make.attributes
        response.should redirect_to(login_path)
      end
    end

    context "when logged in as admin" do
      let(:admin) { Administrator.make! }
      before(:each) { UserSession.create(admin) }

      it "assigns menu and renders a \"show\" template" do
        menu = Menu.make!(:administrator => admin)
        2.times { Dish.make! :menu => menu }
        get :show, :id => menu.id
        assigns[:menu].should eql(menu)
        response.should render_template('show')
      end
    end
  end

  describe "GET edit" do
    context "when not logged in" do
      it "redirects to login page" do
        post :create, :menu => Menu.make.attributes
        response.should redirect_to(login_path)
      end
    end

    context "when logged in as admin" do
      let(:admin) { Administrator.make! }
      before(:each) { UserSession.create(admin) }
      it "assigns the menu and renders the \"edit\" page" do
        menu = Menu.make!(:administrator => admin)
        get :edit, :id => menu.id
        response.should render_template('new')
        assigns[:menu].should eql(menu)
      end
    end
  end

  describe "PUT update" do
    context "with valid menu attrs" do
      before :each do
        Menu.destroy_all
        put :update, :id => Menu.make!.id, :menu => { :date => '1999-10-01' }
      end

      it "updates the date of the menu" do
        assigns[:menu].should be_valid
        assigns[:menu].date.should eql(Time.parse('1999-10-01').to_date)
      end

      it "redirects to \"show\" action" do
        response.should be_redirect
      end

      it "set the success flash message" do
        flash[:notice].should_not be_blank
      end
    end

    context "nested dishes" do
      it "changes dish name" do
        dish = Dish.make!
        put :update, :id => dish.menu.id, :menu => {:dishes_attributes => {0 => {:id => dish.id, :name => 'Awesome stake'}}}
        assigns[:menu].dishes.first.name.should eql('Awesome stake')
      end

      it "destroys a dish" do
        dish = Dish.make!
        menu = dish.menu
        put :update, :id => dish.menu.id, :menu => {:dishes_attributes => {0 => {:id => dish.id, :_destroy => 1}}}
        assigns[:menu].reload.should have(0).dishes
      end

      it "renders the \"new\" template if any of the dishes is not valid" do
        dish = Dish.make!
        put :update, :id => dish.menu.id, :menu => {:dishes_attributes => {0 => {:id => dish.id, :price => 1}}}
        response.should render_template('new')
      end
    end

    context "with invalid menu attrs" do
      before :each do
        Menu.destroy_all
        put :update, :id => Menu.make!.id, :menu => { :date => 'Invalid date' }
      end

      it "renders the \"new\" template" do
        response.should render_template('new')
      end
    end
  end
end

