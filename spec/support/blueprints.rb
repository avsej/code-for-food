require 'machinist/active_record'

Menu.blueprint do
  administrator
  date { sn.to_i.days.from_now.to_date }
end

Menu.blueprint(:with_3_dishes) do
  administrator
  date { sn.to_i.days.from_now.to_date }
  dishes(3)
end

Dish.blueprint do
  menu
  name { "Dish #{sn}" }
  price { 3000 + rand(30)*100 }
end

DishTag.blueprint do
  name { "dish-tag-#{sn}" }
end

Invitation.blueprint do
  sender
  recipient_email { "email.#{sn}@test.com" }
end

User.blueprint do
  email { "email.#{sn}@test.com" }
  password { "password" }
  password_confirmation { object.password }
end

Order.blueprint do
  user
  menu
end

Administrator.blueprint do
end


OrderItem.blueprint do
  order
  dish
end

