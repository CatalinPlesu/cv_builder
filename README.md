# Smart CV Builder

A Ruby on Rails application that allows users to build a master CV, tag content, and dynamically generate customized PDFs using LaTeX templates. Built with Devise authentication, Tailwind CSS, and powered by a Dockerized LaTeX compiler.

## 🚀 Features

- User authentication with Devise
- Create and manage CV entries: skills, experience, education, projects
- Tag each entry with descriptive labels (e.g., "frontend", "devops")
- Generate tailored PDF resumes by selecting specific tags
- Uses LaTeX for high-quality document output
- Modular design for extensibility

## 🙏 Acknowledgments

Special thanks to **Aras Güngöre** for his excellent LaTeX CV template which serves as the foundation for our PDF exports.
- GitHub: [https://github.com/arasgungore/arasgungore-CV](https://github.com/arasgungore/arasgungore-CV)
- Hi there, my name is Aras Güngöre.

## 🔧 Setup Instructions

### Prerequisites

- Ruby >= 3.0
- Rails >= 7.0
- SQLite3
- Docker (for PDF generation)

### Clone the Repo

```bash
git clone https://github.com/CatalinPlesu/cv_builder.git
cd cv_builder
```

### Install Dependencies

```bash
bundle install
yarn install
```

### Setup Database

```bash
rails db:create
rails db:migrate
```

### Run the App

```bash
rails server
```

Visit [http://localhost:3000](http://localhost:3000)

## 🐳 PDF Generation with Docker

This app uses a Docker container to compile LaTeX files into PDFs.

### Clone the Docker Repo

```bash
git clone https://github.com/CatalinPlesu/docker-CV.git
cd docker-CV
```

### Build & Run the Container

```bash
docker build -t latex-cv .
docker run -v $(pwd):/data latex-cv pdflatex your_template.tex
```

This setup is used internally by the Rails app to generate PDFs from LaTeX templates.

## 🧱 Project Structure Overview

- `app/models`: CV item models (Experience, Education, etc.)
- `app/controllers`: Controllers handling user actions and exports
- `app/views`: HTML and LaTeX templates
- `app/assets`: Tailwind CSS and JS assets
- `config/routes.rb`: Routing logic
- `lib/templates/latex`: LaTeX templates for resume generation

## 📦 Technologies Used

- Ruby on Rails
- Tailwind CSS (CDN)
- Devise for authentication
- SQLite3
- Docker (for LaTeX compilation)
- Font Awesome

## 🤝 Contributing

Contributions are welcome! Please fork the repo and submit a pull request.

## 📄 License

MIT License – see [LICENSE](LICENSE) for details.

## 🔗 Links

- GitHub: [https://github.com/CatalinPlesu/cv_builder](https://github.com/CatalinPlesu/cv_builder)
- Docker LaTeX Compiler: [https://github.com/CatalinPlesu/docker-CV](https://github.com/CatalinPlesu/docker-CV)
- Aras Güngöre's CV Template: [https://github.com/arasgungore/arasgungore-CV](https://github.com/arasgungore/arasgungore-CV)
