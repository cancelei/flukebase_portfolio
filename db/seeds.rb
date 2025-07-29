# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create a user first if it doesn't exist
User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end

# Create Personal Information
personal_info = PersonalInfo.find_or_create_by!(id: 1) do |info|
  info.name = "John Doe"
  info.title = "Senior Full-Stack Developer & AI Integration Specialist"
  info.email = "john.doe@example.com"
  info.phone = "+1 (555) 123-4567"
  info.location = "San Francisco, CA"
  info.website = "https://johndoe.dev"
  info.linkedin = "https://linkedin.com/in/johndoe"
  info.github = "https://github.com/johndoe"
  info.twitter = "https://twitter.com/johndoe"
  info.summary = "Experienced full-stack developer with 8+ years of expertise in Ruby on Rails, JavaScript, and modern web technologies. Passionate about building scalable applications and integrating AI solutions to solve complex business problems. Proven track record of leading development teams and delivering high-quality software solutions."
end

# Create Skills with categories and proficiency levels
skills_data = [
  # Programming Languages
  { name: "Ruby", category: "Programming Languages", proficiency_level: 5, position: 1 },
  { name: "JavaScript", category: "Programming Languages", proficiency_level: 5, position: 2 },
  { name: "TypeScript", category: "Programming Languages", proficiency_level: 4, position: 3 },
  { name: "Python", category: "Programming Languages", proficiency_level: 4, position: 4 },
  { name: "Go", category: "Programming Languages", proficiency_level: 3, position: 5 },

  # Frameworks & Libraries
  { name: "Ruby on Rails", category: "Frameworks & Libraries", proficiency_level: 5, position: 1 },
  { name: "React", category: "Frameworks & Libraries", proficiency_level: 5, position: 2 },
  { name: "Vue.js", category: "Frameworks & Libraries", proficiency_level: 4, position: 3 },
  { name: "Node.js", category: "Frameworks & Libraries", proficiency_level: 4, position: 4 },
  { name: "Express.js", category: "Frameworks & Libraries", proficiency_level: 4, position: 5 },

  # Databases
  { name: "PostgreSQL", category: "Databases", proficiency_level: 5, position: 1 },
  { name: "MySQL", category: "Databases", proficiency_level: 4, position: 2 },
  { name: "Redis", category: "Databases", proficiency_level: 4, position: 3 },
  { name: "MongoDB", category: "Databases", proficiency_level: 3, position: 4 },

  # Tools & Technologies
  { name: "Docker", category: "Tools & Technologies", proficiency_level: 4, position: 1 },
  { name: "Git", category: "Tools & Technologies", proficiency_level: 5, position: 2 },
  { name: "Webpack", category: "Tools & Technologies", proficiency_level: 4, position: 3 },
  { name: "Jest", category: "Tools & Technologies", proficiency_level: 4, position: 4 },
  { name: "RSpec", category: "Tools & Technologies", proficiency_level: 5, position: 5 },

  # Cloud Services
  { name: "AWS", category: "Cloud Services", proficiency_level: 4, position: 1 },
  { name: "Heroku", category: "Cloud Services", proficiency_level: 5, position: 2 },
  { name: "Google Cloud", category: "Cloud Services", proficiency_level: 3, position: 3 },
  { name: "DigitalOcean", category: "Cloud Services", proficiency_level: 4, position: 4 }
]

skills_data.each do |skill_data|
  Skill.find_or_create_by!(name: skill_data[:name], category: skill_data[:category]) do |skill|
    skill.proficiency_level = skill_data[:proficiency_level]
    skill.position = skill_data[:position]
  end
end

# Create Education records
educations_data = [
  {
    institution: "University of California, Berkeley",
    degree: "Master of Science",
    field_of_study: "Computer Science",
    start_date: Date.new(2014, 9, 1),
    end_date: Date.new(2016, 5, 15),
    current: false,
    gpa: "3.8",
    achievements: "Specialized in Machine Learning and Artificial Intelligence. Thesis: 'Neural Networks for Natural Language Processing'. Dean's List for 3 consecutive semesters.",
    position: 1
  },
  {
    institution: "San Jose State University",
    degree: "Bachelor of Science",
    field_of_study: "Software Engineering",
    start_date: Date.new(2010, 9, 1),
    end_date: Date.new(2014, 5, 15),
    current: false,
    gpa: "3.7",
    achievements: "Magna Cum Laude graduate. Captain of the Programming Competition Team. Led development of the university's student portal system.",
    position: 2
  }
]

educations_data.each_with_index do |edu_data, index|
  Education.find_or_create_by!(position: edu_data[:position]) do |education|
    education.institution = edu_data[:institution]
    education.degree = edu_data[:degree]
    education.field_of_study = edu_data[:field_of_study]
    education.start_date = edu_data[:start_date]
    education.end_date = edu_data[:end_date]
    education.current = edu_data[:current]
    education.gpa = edu_data[:gpa]
    education.achievements = edu_data[:achievements]
  end
end

# Create Certifications
certifications_data = [
  {
    name: "AWS Certified Solutions Architect",
    issuer: "Amazon Web Services",
    issue_date: Date.new(2023, 3, 15),
    expiry_date: Date.new(2026, 3, 15),
    credential_id: "AWS-CSA-2023-001234",
    credential_url: "https://aws.amazon.com/verification",
    position: 1
  },
  {
    name: "Certified Kubernetes Administrator",
    issuer: "Cloud Native Computing Foundation",
    issue_date: Date.new(2022, 8, 20),
    expiry_date: Date.new(2025, 8, 20),
    credential_id: "CKA-2022-567890",
    credential_url: "https://www.credly.com/badges/sample",
    position: 2
  },
  {
    name: "Ruby Association Certified Ruby Programmer Gold",
    issuer: "Ruby Association",
    issue_date: Date.new(2021, 6, 10),
    expiry_date: nil,
    credential_id: "RUBY-GOLD-2021-112233",
    credential_url: "https://www.ruby.or.jp/en/certification/examination/",
    position: 3
  }
]

certifications_data.each do |cert_data|
  Certification.find_or_create_by!(position: cert_data[:position]) do |cert|
    cert.name = cert_data[:name]
    cert.issuer = cert_data[:issuer]
    cert.issue_date = cert_data[:issue_date]
    cert.expiry_date = cert_data[:expiry_date]
    cert.credential_id = cert_data[:credential_id]
    cert.credential_url = cert_data[:credential_url]
  end
end

# Update existing CV entries to use the new entry_type field
cv_entries_data = [
  {
    position: 1,
    title: "Senior Full-Stack Developer",
    entry_type: "experience",
    company: "TechCorp Inc.",
    location: "San Francisco, CA",
    start_date: Date.new(2020, 3, 1),
    end_date: nil,
    current: true,
    content: "Lead a team of 6 developers in building scalable web applications using Ruby on Rails and React. Implemented AI-powered features that increased user engagement by 40%. Architected microservices infrastructure on AWS, reducing response times by 60%. Mentored junior developers and established code review processes that improved code quality significantly."
  },
  {
    position: 2,
    title: "Full-Stack Developer",
    entry_type: "experience",
    company: "StartupXYZ",
    location: "Palo Alto, CA",
    start_date: Date.new(2018, 1, 15),
    end_date: Date.new(2020, 2, 28),
    current: false,
    content: "Developed and maintained multiple client-facing applications using Ruby on Rails, JavaScript, and PostgreSQL. Built RESTful APIs serving 10K+ daily active users. Implemented automated testing strategies that reduced bug reports by 70%. Collaborated with product and design teams to deliver features on tight deadlines."
  },
  {
    position: 3,
    title: "Software Engineer",
    entry_type: "experience",
    company: "DevSolutions LLC",
    location: "Mountain View, CA",
    start_date: Date.new(2016, 6, 1),
    end_date: Date.new(2017, 12, 31),
    current: false,
    content: "Worked on enterprise software solutions using Java and Spring Framework. Developed database optimization strategies that improved query performance by 50%. Participated in agile development processes and contributed to architectural decisions for scalable system design."
  }
]

cv_entries_data.each do |entry_data|
  cv_entry = CvEntry.find_by(position: entry_data[:position])

  if cv_entry
    # Update existing entry
    cv_entry.update!(
      title: entry_data[:title],
      content: entry_data[:content],
      entry_type: entry_data[:entry_type],
      company: entry_data[:company],
      location: entry_data[:location],
      start_date: entry_data[:start_date],
      end_date: entry_data[:end_date],
      current: entry_data[:current]
    )
  else
    # Create new entry with all required fields
    CvEntry.create!(
      position: entry_data[:position],
      title: entry_data[:title],
      content: entry_data[:content],
      entry_type: entry_data[:entry_type],
      company: entry_data[:company],
      location: entry_data[:location],
      start_date: entry_data[:start_date],
      end_date: entry_data[:end_date],
      current: entry_data[:current]
    )
  end
end

# Create tags
rails_tag = Tag.find_or_create_by!(name: 'Ruby on Rails')
javascript_tag = Tag.find_or_create_by!(name: 'JavaScript')
api_tag = Tag.find_or_create_by!(name: 'API Development')
ai_tag = Tag.find_or_create_by!(name: 'AI/ML')

# Create projects
project1 = Project.find_or_create_by!(title: 'E-commerce Platform', slug: 'ecommerce-platform') do |project|
  project.description = 'A comprehensive e-commerce platform built with Ruby on Rails and React, featuring real-time inventory management, payment processing, and AI-powered product recommendations.'
  project.github_url = 'https://github.com/johndoe/ecommerce-platform'
  project.demo_url = 'https://demo-ecommerce.johndoe.dev'
  project.published = true
  project.source = 'manual'
end
project1.tags = [ rails_tag, javascript_tag, ai_tag ]

project2 = Project.find_or_create_by!(title: 'Task Management API', slug: 'task-management-api') do |project|
  project.description = 'RESTful API for task management with user authentication, team collaboration features, and real-time notifications using WebSockets.'
  project.github_url = 'https://github.com/johndoe/task-api'
  project.published = true
  project.source = 'manual'
end
project2.tags = [ rails_tag, api_tag ]

# Create blog posts
blog1 = BlogPost.find_or_create_by!(title: 'Building Scalable Rails Applications', slug: 'building-scalable-rails-applications') do |post|
  post.content = 'In this post, I share my experience building scalable Ruby on Rails applications that can handle millions of users...'
  post.published = true
  post.published_at = 2.weeks.ago
end

blog2 = BlogPost.find_or_create_by!(title: 'Integrating AI into Web Applications', slug: 'integrating-ai-web-applications') do |post|
  post.content = 'Artificial Intelligence is transforming how we build web applications. Here are practical strategies for integration...'
  post.published = true
  post.published_at = 1.week.ago
end

puts "Sample data created successfully!"
puts "Personal Info: #{PersonalInfo.count} record"
puts "Skills: #{Skill.count} records"
puts "Education: #{Education.count} records"
puts "Certifications: #{Certification.count} records"
puts "CV Entries: #{CvEntry.count} records"
puts "Projects: #{Project.count} records"
puts "Blog Posts: #{BlogPost.count} records"
