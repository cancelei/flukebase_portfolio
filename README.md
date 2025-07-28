# Flukebase Portfolio

A comprehensive portfolio application built with **Ruby on Rails 8.0.2**, featuring AI chat integration, Flukebase project syncing, custom SMTP configuration, and modern UI with **Tailwind CSS** and **Hotwire**.

## ✨ Features

- **Modern Rails 8 Stack**: Built with Rails 8.0.2, PostgreSQL, Tailwind CSS, and Hotwire (Turbo + Stimulus)
- **Admin Panel**: Complete CRUD interface for managing projects, blog posts, CV entries, and settings
- **AI Chat Integration**: OpenAI-powered chat assistant that answers questions about your CV
- **Flukebase Sync**: Automatic project synchronization from Flukebase.me
- **Blog System**: Rich text blog posts with ActionText
- **File Management**: Resume PDF uploads with Active Storage
- **Email Subscriptions**: Newsletter signup with custom SMTP configuration
- **Responsive Design**: Mobile-first design with Tailwind CSS
- **Security**: Devise authentication, Pundit authorization, CSRF protection

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Ruby on Rails 8.0.2 |
| **Database** | PostgreSQL |
| **Frontend** | Hotwire (Turbo + Stimulus) |
| **Styling** | Tailwind CSS |
| **Authentication** | Devise |
| **Authorization** | Pundit |
| **Background Jobs** | Solid Queue |
| **Caching** | Solid Cache |
| **File Uploads** | Active Storage |
| **Rich Text** | ActionText |
| **AI Integration** | OpenAI API |
| **HTTP Client** | Faraday |

## 🚀 Quick Start

### Prerequisites

- Ruby 3.2+
- PostgreSQL 12+
- Node.js (for Tailwind CSS)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd flukebase_portfolio
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys and configuration
   ```

5. **Start the application**
   ```bash
   bin/dev
   ```

6. **Access the application**
   - Visit: http://localhost:3000
   - Admin login: admin@example.com / password

## 🔧 Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
# OpenAI API for AI chat functionality
OPENAI_API_KEY=your_openai_api_key_here

# Flukebase API integration
FLUKEBASE_API_KEY=your_flukebase_api_key_here
FLUKEBASE_API_URL=https://flukebase.me/api/v1/

# SMTP configuration
SMTP_DEFAULT_FROM=no-reply@yourdomain.com
```

### Database Configuration

The application uses PostgreSQL by default. Update `config/database.yml` if needed:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: flukebase_portfolio_development
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV['DATABASE_USER'] || 'postgres' %>
  password: <%= ENV['DATABASE_PASSWORD'] || '' %>
  host: <%= ENV['DATABASE_HOST'] || 'localhost' %>
```

## 📋 Usage

### Admin Panel

Access the admin panel at `/admin/dashboard` after logging in:

- **Projects**: Manage your portfolio projects with images, tags, and links
- **Blog Posts**: Create and publish blog posts with rich text content
- **CV Entries**: Manage your CV sections and content
- **Resume**: Upload and manage your PDF resume
- **Subscribers**: View email subscribers
- **Settings**: Configure site settings, SMTP, and integrations

### Public Features

- **Homepage**: Hero section with featured projects and recent blog posts
- **Projects**: Filterable project gallery with search and tag filtering
- **Blog**: Published blog posts with rich text content
- **CV**: Professional CV display with structured sections
- **Resume**: PDF resume download
- **AI Chat**: Interactive chat about your professional background
- **Newsletter**: Email subscription for updates

### Flukebase Integration

To sync projects from Flukebase:

1. Set your Flukebase API key in environment variables
2. Enable integration in admin settings
3. Run manual sync or wait for automatic daily sync

```bash
# Manual sync
bin/rails runner "FlukebaseSyncService.call"
```

## 🔒 Security Features

- **Authentication**: Devise-based user authentication
- **Authorization**: Pundit policies for admin access control
- **CSRF Protection**: Rails built-in CSRF protection
- **Parameter Filtering**: Strong parameters for all forms
- **SQL Injection Prevention**: ActiveRecord ORM protection
- **XSS Protection**: Rails built-in XSS protection

## 🎨 Customization

### Styling

The application uses Tailwind CSS for styling. Customize the design by:

1. Editing Tailwind classes in views
2. Adding custom CSS in `app/assets/stylesheets/application.css`
3. Configuring Tailwind in `tailwind.config.js`

### Content

1. **Site Settings**: Configure via admin panel or directly in database
2. **CV Content**: Add/edit CV entries through admin interface
3. **Projects**: Add projects manually or sync from Flukebase
4. **Blog**: Create blog posts with ActionText rich editor

## 🚀 Deployment

### Heroku

1. **Create Heroku app**
   ```bash
   heroku create your-app-name
   ```

2. **Add PostgreSQL addon**
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

3. **Set environment variables**
   ```bash
   heroku config:set OPENAI_API_KEY=your_key
   heroku config:set FLUKEBASE_API_KEY=your_key
   ```

4. **Deploy**
   ```bash
   git push heroku main
   heroku run rails db:migrate
   heroku run rails db:seed
   ```

### CapRover

1. **Prepare captain-definition**
   ```json
   {
     "schemaVersion": 2,
     "dockerfilePath": "./Dockerfile"
   }
   ```

2. **Deploy via CapRover CLI**
   ```bash
   caprover deploy
   ```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
bin/rails test

# Run system tests
bin/rails test:system

# Run specific test file
bin/rails test test/models/project_test.rb
```

## 📦 Background Jobs

The application uses Solid Queue for background job processing:

- **Flukebase Sync**: Daily automatic project synchronization
- **Email Delivery**: Newsletter and notification emails

Monitor jobs in the admin panel or via Rails console:

```ruby
# Check job status
SolidQueue::Job.all

# Manual job execution
FlukebaseSyncJob.perform_now
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](../../issues) page
2. Create a new issue with detailed information
3. Include error messages, logs, and steps to reproduce

## 🙏 Acknowledgments

- Built with [Ruby on Rails 8](https://rubyonrails.org/)
- Styled with [Tailwind CSS](https://tailwindcss.com/)
- Powered by [Hotwire](https://hotwired.dev/)
- AI integration via [OpenAI API](https://openai.com/api/)
- Inspired by modern portfolio design patterns
