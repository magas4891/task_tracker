# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user_params = {
  email: 'test@example.com',
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  password: 'password'
}
user = User.create(user_params)

5.times do
  cat = user.categories.create(name: Faker::Hobby.activity)
  10.times do
    cat.tasks.create(user: user,
                     title: Faker::Movie.title,
                     description: Faker::ChuckNorris.fact,
                     due_date: Faker::Date.forward)
  end
end

20.times do
  user.tasks.create(title: Faker::Movie.title,
                    description: Faker::ChuckNorris.fact,
                    due_date: Faker::Date.forward)
end
