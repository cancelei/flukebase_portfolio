# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
end

# Create site settings
SiteSetting.find_or_create_by!(key: 'flukebase_integration_enabled') do |setting|
  setting.value = 'false'
  setting.value_type = 'boolean'
end

SiteSetting.find_or_create_by!(key: 'flukebase_api_key') do |setting|
  setting.value = ''
  setting.value_type = 'string'
end

SiteSetting.find_or_create_by!(key: 'flukebase_api_url') do |setting|
  setting.value = 'https://flukebase.me/api/v1/'
  setting.value_type = 'string'
end

SiteSetting.find_or_create_by!(key: 'flukebase_last_sync') do |setting|
  setting.value = ''
  setting.value_type = 'string'
end

SiteSetting.find_or_create_by!(key: 'flukebase_sync_count') do |setting|
  setting.value = '0'
  setting.value_type = 'integer'
end

SiteSetting.find_or_create_by!(key: 'onboarding_complete') do |setting|
  setting.value = 'true'
  setting.value_type = 'boolean'
end

SiteSetting.find_or_create_by!(key: 'site_name') do |setting|
  setting.value = 'Flukebase Portfolio'
  setting.value_type = 'string'
end

SiteSetting.find_or_create_by!(key: 'blog_enabled') do |setting|
  setting.value = 'true'
  setting.value_type = 'boolean'
end

SiteSetting.find_or_create_by!(key: 'shared_editing_enabled') do |setting|
  setting.value = 'true'
  setting.value_type = 'boolean'
end

SiteSetting.find_or_create_by!(key: 'resume_enabled') do |setting|
  setting.value = 'true'
  setting.value_type = 'boolean'
end

SiteSetting.find_or_create_by!(key: 'ai_chat_enabled') do |setting|
  setting.value = 'true'
  setting.value_type = 'boolean'
end

# Create tags
rails_tag = Tag.find_or_create_by!(name: 'Rails')
javascript_tag = Tag.find_or_create_by!(name: 'JavaScript')
react_tag = Tag.find_or_create_by!(name: 'React')
ai_tag = Tag.find_or_create_by!(name: 'AI')
api_tag = Tag.find_or_create_by!(name: 'API')

# Create sample projects
project1 = Project.find_or_create_by!(title: 'Flukebase Portfolio', slug: 'flukebase-portfolio') do |project|
  project.description = 'A comprehensive portfolio application built with Ruby on Rails 8, featuring AI chat integration, Flukebase sync, and modern UI with Tailwind CSS.'
  project.github_url = 'https://github.com/example/flukebase-portfolio'
  project.demo_url = 'https://portfolio.example.com'
  project.published = true
  project.source = 'manual'
end
project1.tags = [ rails_tag, javascript_tag, ai_tag ]

project2 = Project.find_or_create_by!(title: 'AI Chat Assistant', slug: 'ai-chat-assistant') do |project|
  project.description = 'An intelligent chat assistant powered by OpenAI API with context-aware responses and conversation history.'
  project.github_url = 'https://github.com/example/ai-chat'
  project.published = true
  project.source = 'manual'
end
project2.tags = [ ai_tag, api_tag, javascript_tag ]

project3 = Project.find_or_create_by!(title: 'React Dashboard', slug: 'react-dashboard') do |project|
  project.description = 'A modern dashboard application built with React and TypeScript, featuring real-time data visualization and responsive design.'
  project.github_url = 'https://github.com/example/react-dashboard'
  project.demo_url = 'https://dashboard.example.com'
  project.published = true
  project.source = 'manual'
end
project3.tags = [ react_tag, javascript_tag ]

project4 = Project.find_or_create_by!(title: 'API Integration Tool', slug: 'api-integration-tool') do |project|
  project.description = 'A powerful tool for integrating multiple APIs with automated testing and documentation generation.'
  project.published = true
  project.source = 'manual'
end
project4.tags = [ api_tag, javascript_tag ]

# Create CV entries
entry1 = CvEntry.find_or_create_by!(position: 1, title: 'Professional Summary') do |entry|
  entry.content = 'Experienced full-stack developer with 5+ years of expertise in Ruby on Rails, JavaScript, and modern web technologies. Passionate about building scalable applications and integrating AI solutions to solve complex problems.'
end

entry2 = CvEntry.find_or_create_by!(position: 2, title: 'Technical Skills') do |entry|
  entry.content = 'Languages: Ruby, JavaScript, TypeScript, Python<br>Frameworks: Ruby on Rails, React, Node.js<br>Databases: PostgreSQL, MySQL, Redis<br>Tools: Docker, Git, AWS, Heroku<br>Specialties: API development, AI integration, full-stack development'
end

entry3 = CvEntry.find_or_create_by!(position: 3, title: 'Work Experience') do |entry|
  entry.content = 'Senior Full-Stack Developer (2020-Present)<br>• Led development of multiple Rails applications<br>• Integrated AI/ML solutions using OpenAI API<br>• Mentored junior developers and conducted code reviews<br>• Improved application performance by 40%'
end

entry4 = CvEntry.find_or_create_by!(position: 4, title: 'Education') do |entry|
  entry.content = 'Bachelor of Science in Computer Science<br>University of Technology (2016-2020)<br>• Focus on software engineering and web development<br>• Graduated Magna Cum Laude'
end

# Create sample blog post
blog_post = BlogPost.find_or_create_by!(title: 'Building Modern Rails Applications', slug: 'building-modern-rails-applications') do |post|
  post.content = '<p>Rails 8 brings exciting new features and improvements that make building modern web applications easier than ever. In this post, we\'ll explore the key features and how to leverage them in your projects.</p><p><strong>Key features include:</strong></p><ul><li>Improved performance with Solid Queue and Solid Cache</li><li>Better developer experience with enhanced tooling</li><li>Enhanced security with built-in protections</li><li>Modern JavaScript integration with Hotwire</li></ul><p>These improvements make Rails 8 an excellent choice for building scalable, maintainable web applications.</p>'
  post.published = true
  post.published_at = 1.week.ago
end

# Create default resume
Resume.find_or_create_by!(title: 'Default Resume')

puts "Seed data created successfully!"
puts "Admin user: admin@example.com / password"
puts "#{Project.count} projects created"
puts "#{CvEntry.count} CV entries created"
puts "#{BlogPost.count} blog posts created"
puts "#{Tag.count} tags created"
