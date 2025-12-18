# 🚀 NEXUS AI STUDIO v3.1 - ZSH Configuration

> **Comprehensive Terminal Configuration for macOS Big Sur Intel**  
> Production-ready with AI integration, system monitoring, and advanced utilities

---

## 📋 Quick Links

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Commands](#commands)
- [Project Structure](#project-structure)

---

## Overview

**NEXUS AI Studio** is a unified, production-grade ZSH configuration designed specifically for macOS Big Sur Intel systems. It combines real-time system monitoring, AI integration, advanced tooling, and productivity features into one seamless experience.

---

## ✨ Features

### 🎨 Dashboard & Visualization
- Real-time system metrics dashboard with auto-refresh
- Live CPU, Memory, Disk, Battery monitoring
- Health score calculations
- TrueColor (24-bit) and 256-color support

### 🖥️ System Monitoring
- Comprehensive metrics display
- Process and network tracking
- Temperature monitoring
- Battery status and uptime

### 🤖 AI Intelligence
- Multi-provider support (OpenAI, Claude, Groq, DeepSeek, Google, Ollama)
- Code review, debugging, optimization
- Advanced prompt engineering

### 📦 Tool Management
- Database of 1000+ development tools
- Multiple installation methods per tool
- Batch installation support

### 📋 TODO Management
- Create, list, complete tasks
- Priority, due dates, tags support
- Statistical reporting

### ⚙️ Auto Systems
- Auto-healing and optimization
- Performance recommendations
- Smart backup creation

### 🛡️ Security & Privacy
- File encryption/decryption
- Permission auditing
- Security hardening

---

## 🚀 Quick Start

### Installation (One Command)

```bash
# Clone and install
git clone https://github.com/bigolivenyc-cloud/ZSH.git
cd ZSH
bash install.sh

# Reload your shell
source ~/.zshrc
```

### First Commands

```bash
quantum-help          # Display help menu
quantum-dashboard     # View system dashboard
quantum-metrics       # Show system metrics
quantum-stats         # Quick statistics
```

---

## 📥 Installation

### Prerequisites
- macOS Big Sur or later
- zsh 5.0+
- Terminal with 256-color support

### Step-by-Step

1. **Clone Repository**
   ```bash
   git clone https://github.com/bigolivenyc-cloud/ZSH.git
   cd ZSH
   ```

2. **Run Installer**
   ```bash
   chmod +x install.sh
   bash install.sh
   ```

3. **Reload Configuration**
   ```bash
   source ~/.zshrc
   ```

4. **Verify Installation**
   ```bash
   quantum-help
   ```

---

## 🎯 Commands Reference

### Dashboard & Monitoring
| Command | Description |
|---------|-------------|
| `quantum-dashboard` | Live system dashboard |
| `quantum-metrics` | Detailed system metrics |
| `quantum-stats` | Quick statistics |
| `quantum-help` | Help menu |

### Git Shortcuts
| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git pull` |
| `gph` | `git push` |

### System Management
```bash
quantum-heal          # Auto-fix system
quantum-backup        # Create backup
quantum-update        # Check updates
```

---

## 📁 Project Structure

```
ZSH/
├── install.sh                    # ⭐ Run this to install
├── README.md                     # Documentation
└── zsh-config/
    ├── zsh/
    │   └── zshrc.txt            # Enhanced zshrc
    └── ultra-zsh/
        ├── nexus_bootstrap.zsh  # Bootstrap script
        ├── modules/             # Core modules
        │   ├── system_metrics.zsh
        │   ├── enhanced_dashboard.zsh
        │   └── help_system.zsh
        └── plugins/             # Plugin system
```

### After Installation
```
~/.config/ultra-zsh/
├── modules/         # Loaded modules
├── plugins/         # User plugins
├── backups/         # Configuration backups
├── logs/            # Activity logs
├── cache/           # Temporary cache
├── ai/              # AI configurations
├── security/        # Security data
└── dashboard/       # Dashboard configs
```

---

## 🔧 Configuration

### Main Configuration
- **Location**: `~/.zshrc`
- **Backup**: `~/.config/ultra-zsh/backups/`

### Customize Settings

Edit `~/.zshrc`:
```bash
# Change editor
export EDITOR="vim"

# Set terminal type
export TERM="xterm-256color"

# Adjust dashboard refresh
quantum-dashboard 2    # 2-second refresh
```

---

## 🆘 Troubleshooting

### Commands not found
```bash
source ~/.zshrc
```

### Colors not displaying
```bash
export TERM=xterm-256color
```

### Permission denied
```bash
chmod +x install.sh
bash install.sh
```

### Restore original zshrc
```bash
cp ~/.config/ultra-zsh/backups/.zshrc.backup ~/.zshrc
source ~/.zshrc
```

---

## 📚 Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `NEXUS_HOME` | `~/.config/ultra-zsh` | Config directory |
| `EDITOR` | `nvim` | Default editor |
| `TERM` | `xterm-256color` | Terminal type |
| `HISTSIZE` | `50000` | History size |

---

## 🎓 Advanced Usage

### Create Custom Module

```bash
cat > ~/.config/ultra-zsh/modules/my_module.zsh << 'EOF'
#!/usr/bin/env zsh
# My custom module

my_command() {
    echo "Hello from my module"
}

alias my-cmd='my_command'
EOF
```

### Add Custom Aliases

Edit `~/.zshrc` and add:
```bash
alias myalias='your command here'
source ~/.zshrc
```

---

## 🗑️ Uninstallation

```bash
# Restore original config
cp ~/.config/ultra-zsh/backups/.zshrc.backup ~/.zshrc

# Remove configuration
rm -rf ~/.config/ultra-zsh

# Reload
source ~/.zshrc
```

---

## 📝 Changelog

### v3.1.0 (Current)
- ✨ Unified build and installation system
- ✨ Enhanced dashboard with TrueColor support
- ✨ Optimized metrics for Big Sur Intel
- ✨ Comprehensive help system
- ✨ Production-ready configuration

### v3.0.0
- Initial release with core features

---

## 📄 License

Open source under MIT License

---

## 🙏 Support

- **Documentation**: See README.md and `quantum-help`
- **Issues**: [GitHub Issues](https://github.com/bigolivenyc-cloud/ZSH)
- **Logs**: `~/.config/ultra-zsh/logs/`

---

## Archived Documentation

To reduce clutter, non-critical, duplicate, or delivery-focused documents have been moved to `archived_docs/`. This includes historical specs, installers, and delivery manifests.

### Examples of Archived Files:
- `00_START_HERE.md`
- `QUICKSTART.md`
- `NEXUS_QUANTUM_*` files
- `PROJECT_*` summaries

To restore any file, use:
```bash
git mv archived_docs/<filename>.md ./
git commit -m "restore <filename> from archive"
```

---

**Made with ❤️ for terminal enthusiasts | [GitHub](https://github.com/bigolivenyc-cloud/ZSH)**

---

## 🏗️ Professional Development Infrastructure (v4.1.0)

### Testing & Quality Assurance

The platform now includes comprehensive testing infrastructure:

- **Unit Tests**: Pytest-based testing with 80% coverage requirement
- **Shell Tests**: BATS framework for shell script validation
- **Integration Tests**: Component interaction testing
- **Security Scanning**: Automated vulnerability detection with Bandit
- **Code Quality**: Pylint, MyPy, Flake8, ShellCheck integration

```bash
# Run all tests
make test

# Run specific test suites
make test-unit
make test-integration
make test-shell

# Check coverage
make coverage
```

### CI/CD Pipeline

Automated workflows for continuous integration and deployment:

- **GitHub Actions**: Automated testing on push/PR
- **Multi-Python Testing**: Tests run on Python 3.8, 3.9, 3.10, 3.11
- **Security Scanning**: Automated security checks
- **Code Quality Gates**: Linting and formatting verification
- **Deployment Automation**: Streamlined deployment process

### Infrastructure as Code

Production-ready deployment configurations:

- **Docker**: Multi-stage builds for optimized images
- **Docker Compose**: Complete local development stack with PostgreSQL, Redis, Prometheus, Grafana
- **Kubernetes**: Production deployment manifests with health checks, auto-scaling
- **Monitoring**: Prometheus metrics collection and Grafana dashboards

```bash
# Local development
make docker-up

# Production deployment
make k8s-deploy
```

### Comprehensive Documentation

- 📖 **[Architecture Guide](docs/architecture/ARCHITECTURE.md)**: System design and patterns
- 🔌 **[API Documentation](docs/api/API.md)**: Complete API reference
- 💻 **[Development Guide](docs/guides/DEVELOPMENT.md)**: Setup and workflow
- 🔒 **[Security Guide](docs/guides/SECURITY.md)**: Best practices and patterns
- ⚡ **[Performance Guide](docs/guides/PERFORMANCE.md)**: Optimization strategies
- 🔧 **[Troubleshooting Guide](docs/guides/TROUBLESHOOTING.md)**: Common issues
- 🚀 **[Deployment Guide](docs/guides/DEPLOYMENT.md)**: Multi-environment deployment
- 🗺️ **[Roadmap](ROADMAP.md)**: Future plans and features

### Developer Experience

Enhanced tools for productivity:

- **VS Code Integration**: Pre-configured settings, debugging, extensions
- **EditorConfig**: Consistent formatting across editors
- **Pre-commit Hooks**: Automated checks before commits
- **Makefile**: Common tasks automation (`make help` for all commands)
- **Contributing Guide**: Clear contribution guidelines

### Quick Start for Developers

```bash
# Clone and setup
git clone https://github.com/Q-T0NLY/zsh.git
cd zsh

# Install dependencies and setup environment
make install

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run tests
make test

# Start development environment
make docker-up

# View all available commands
make help
```

### Automation Commands

The Makefile provides extensive automation:

```bash
make install       # Install dependencies
make test          # Run all tests
make lint          # Run all linters
make format        # Format code
make security      # Security scans
make docker-up     # Start services
make k8s-deploy    # Deploy to Kubernetes
make coverage      # Generate coverage report
make clean         # Clean artifacts
```

### Monitoring & Observability

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization dashboards
- **Structured Logging**: JSON format for easy parsing
- **Health Checks**: Liveness and readiness probes
- **Distributed Tracing**: Request correlation

Access monitoring:
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3001` (admin/admin)

### Security Features

- **Secret Management**: Environment-based configuration
- **Security Scanning**: Automated vulnerability detection
- **Input Validation**: Comprehensive sanitization patterns
- **Authentication**: JWT-based auth patterns
- **HTTPS/TLS**: Production security

### Architecture Decision Records (ADRs)

- [ADR-001: Dataclasses for Configuration](docs/adr/001-dataclasses-for-config.md)
- [ADR-002: Async/Await Pattern](docs/adr/002-async-await-pattern.md)

### What's New in v4.1.0

- ✅ Comprehensive testing infrastructure
- ✅ CI/CD pipelines with GitHub Actions
- ✅ Production-ready Docker and Kubernetes configs
- ✅ Complete documentation suite
- ✅ Monitoring and observability stack
- ✅ Security best practices and scanning
- ✅ Developer productivity tools
- ✅ Performance optimization guides
- ✅ Troubleshooting resources
- ✅ Deployment automation

See [RELEASE_NOTES.md](RELEASE_NOTES.md) for detailed changes.

---

## 📊 Project Status

![Tests](https://img.shields.io/badge/tests-passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-80%25-green)
![Python](https://img.shields.io/badge/python-3.8%2B-blue)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Kubernetes](https://img.shields.io/badge/kubernetes-ready-blue)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 🤝 Contributing

We welcome contributions! Please see:

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CONTRIBUTING.md#code-of-conduct)
- [Development Guide](docs/guides/DEVELOPMENT.md)
- [Roadmap](ROADMAP.md)

### Quick Contribution Steps

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Run linters (`make lint`)
6. Commit (`git commit -m 'feat: add amazing feature'`)
7. Push (`git push origin feature/amazing-feature`)
8. Open a Pull Request

---

## 📞 Support & Community

- **Documentation**: Comprehensive guides in `docs/`
- **Issues**: [GitHub Issues](https://github.com/Q-T0NLY/zsh/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Q-T0NLY/zsh/discussions)
- **Security**: See [Security Policy](docs/guides/SECURITY.md)

---

## 🗺️ Future Roadmap

See [ROADMAP.md](ROADMAP.md) for planned features including:

- GraphQL API
- Advanced monitoring and APM integration
- Multi-tenancy support
- Machine learning capabilities
- Mobile SDKs
- Plugin marketplace

---

