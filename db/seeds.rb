# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Message.delete_all
Inbox.delete_all
User.delete_all

2.times do
	faker_email = Faker::Internet.email
	user = User.create(email: faker_email,
										 password: Devise.friendly_token[0, 20])

	rand(1..5).times do
		faker_name = Faker::Quote.famous_last_words
		inbox = Inbox.create(name: faker_name,
												 user: user)

		rand(1..5).times do
			message_body = Faker::Lorem.paragraph
			Message.create(body: message_body,
										 inbox: inbox,
										 user_id: rand(1..2))
		end
	end
end

p "#{User.count} users created"
p "#{Inbox.count} inboxes created"
p "#{Message.count} messages created"