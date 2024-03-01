  Role.create(
    name: 'po',
  )
  Role.create(
    name: 'qa',
  )
  Role.create(
    name: 'dev',
  )


50.times do
  User.create(
    name: Faker::Name.first_name,
    email: "#{Faker::Name.first_name.downcase}@gmail.com",
    password: "12345678",
    email_confirmed: true
  )
end


50.times do |n|
  Project.create(
    name: Faker::Name.first_name,
    type_test: :manual,
    platform: :web
  )
  
  10.times do |d|
    Version.create(
      project_id: n + 1,
      name: Faker::Name.first_name,
      status: true 
    )
    Scenario.create(
      project_id: n + 1,
      name: Faker::Name.first_name
    )
    5.times do |xx|
      TestCase.create(
        scenario_id: d + 1,
        version_id: d + 1,
        expectation: Faker::Marketing.buzzwords,
        test_step: Faker::Name.first_name,
        testcase: Faker::Name.first_name,
        pre_condition: Faker::Marketing.buzzwords,
        test_category: :positif 
      )
    end
  end
end

# 50.times do |n|
#   @n = n+4
#   Profile.create(
#     user_id: @n,
#     phone_number: "0854326788",
#     dob: "2023-02-03",
#     gender: 1,
#     bio: Faker::Marketing.buzzwords
#   )
# end

