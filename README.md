# Agentic Development Framework

Enterprise-scale agentic development framework showcasing **Claude Code** across monorepo and multi-repo organizations.

## 🎯 Overview

This framework demonstrates **127 completed work items** spanning infrastructure setup, service scaffolding, and automation across:

- **2 GitHub Organizations**: `omnibase-poc` (monorepo), `polybase-poc` (multi-repo)
- **20 Repositories**: 19 multi-repo services + 1 enterprise monorepo
- **6 Teams**: Backend, BFF, Frontend, Mobile, Data Platform, Platform SRE
- **8 Technology Stacks**: Java/Spring Boot, Node.js/TypeScript, React, Swift, Kotlin, React Native, Terraform, SQL

**Timeline**: October 2025 - April 2026

---

## 📚 Documentation

### Getting Started

1. **[QUICK_START.md](QUICK_START.md)** - 5-minute setup guide
2. **[docs/SETUP.md](docs/SETUP.md)** - Detailed setup instructions
3. **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture overview

### Implementation Guides

- **[docs/GITHUB_INTEGRATION.md](docs/GITHUB_INTEGRATION.md)** - GitHub Projects & Issues integration
- **[docs/AGENT_HANDOFF.md](docs/AGENT_HANDOFF.md)** - Agent-to-agent handoff patterns
- **[reference/archives/](reference/archives/)** - Historical implementation context

---

## 🚀 Quick Start

### Prerequisites

- GitHub CLI (`gh`) authenticated
- Git configured
- Claude Code installed
- Direnv (optional but recommended)

### Setup

```bash
# Clone the framework
git clone https://github.com/leo-levintza-lab49/agentic-development-framework.git
cd agentic-development-framework

# Configure environment
cp .env.template .env
cp .envrc.template .envrc
# Edit .env with your tokens and paths

# Load environment (if using direnv)
direnv allow

# Or source manually
source .envrc

# Verify setup
./scripts/validate.sh
```

---

## 🏗️ Framework Structure

```
agentic-development-framework/
├── scripts/              # Orchestration scripts (4,558 LOC)
│   ├── *.sh             # 11 main scripts
│   └── lib/             # 19 library scripts
├── templates/           # Scaffolding templates
│   ├── common/          # Shared configurations
│   ├── team-configs/    # 6 team-specific configs
│   └── technology/      # 8 technology stack templates
├── config/              # Metadata (repositories.csv, teams.csv, etc.)
├── .claude/             # Claude Code configuration
│   ├── agents/          # Documentation & GitHub integration agents
│   ├── skills/          # Reusable skills
│   └── scripts/         # Hook scripts
├── docs/                # Framework documentation
└── reference/           # Historical archives
```

---

## 🎓 What This Framework Does

### Infrastructure Management

- **Create GitHub Organizations** with team structure
- **Generate Repositories** (monorepo or multi-repo patterns)
- **Configure Teams & Permissions** automatically
- **Set up CI/CD Pipelines** (GitHub Actions)

### Service Scaffolding

Generate production-ready services with:
- Technology-specific templates (Java, Node.js, React, Mobile, etc.)
- Team-specific configurations
- Claude Code integration
- Security and quality rules
- Testing frameworks
- Dockerfiles

### Automation & Integration

- **Claude Code Agents** for documentation generation and GitHub sync
- **GitHub Projects Integration** for roadmap tracking
- **Issue-Based Agent Handoff** for distributed work
- **Automated PR Generation** with throttling and validation

---

## 🤖 Claude Code Integration

### Agents

- **doc-writer**: Generate technical documentation
- **doc-architect**: Orchestrate multi-repo documentation
- **doc-analyzer**: Deep code analysis with Opus
- **issue-sync**: Sync tasks to GitHub Issues
- **roadmap-update**: Update GitHub Projects
- **agent-handoff**: Manage agent-to-agent handoffs

### Skills

- `/doc-check` - Check documentation freshness
- `/doc-update` - Update documentation
- `/doc-generate` - Generate full documentation
- `/issue-sync` - Sync to GitHub Issues
- `/roadmap-sync` - Update roadmap
- `/agent-handoff` - Create handoff issue

---

## 📊 Results

### Completed Work (127 Items)

- **95 Pull Requests** across 18 multi-repo repositories
- **19 Services Generated** in enterprise monorepo
- **13 Framework Enhancements** (scripts, documentation, presentation materials)

### Organizations Created

#### omnibase-poc (Monorepo)
- 1 enterprise monorepo repository
- 19 services across 6 teams
- Team-based directory structure

#### polybase-poc (Multi-Repo)
- 19 individual repositories
- Full CI/CD per repository
- Independent release cycles

---

## 🔧 Key Scripts

### Infrastructure

```bash
# Set up complete infrastructure
./scripts/setup-github-infrastructure.sh

# Apply team configurations
./scripts/apply-team-configs.sh

# Deploy documentation system
./scripts/deploy-doc-system.sh
```

### Service Generation

```bash
# Generate service in multi-repo
./scripts/lib/repo-creation.sh create polybase-poc user-service java-service backend

# Generate service in monorepo
./scripts/generate-monorepo-service.sh backend user-service java
```

### Documentation

```bash
# Generate documentation automatically
./scripts/automated-doc-generation.sh

# Check documentation freshness
./.claude/scripts/check-doc-freshness.sh
```

---

## 🎯 Use Cases

### For Software Teams

- Bootstrap new microservices infrastructure
- Standardize project scaffolding across teams
- Implement consistent quality gates
- Automate repetitive setup tasks

### For Platform Engineers

- Template infrastructure-as-code patterns
- Deploy standardized monitoring/observability
- Enforce security and compliance rules
- Scale to dozens or hundreds of repositories

### For AI/Agent Developers

- Study agent-to-agent collaboration patterns
- Learn Claude Code integration techniques
- Understand GitHub-based workflow automation
- Explore multi-org, multi-repo orchestration

---

## 🤝 Contributing

This is a case study/reference implementation. Feel free to:

- Fork and adapt for your organization
- Study the patterns and scripts
- Open issues for questions or suggestions
- Share your learnings

---

## 📝 License

MIT License - see [LICENSE](LICENSE) for details

---

## 🙏 Acknowledgments

Built with [Claude Code](https://claude.ai/claude-code) by Anthropic.

**Co-Authored-By**: Claude Sonnet 4.5 <noreply@anthropic.com>

---

## 📖 Learn More

- **GitHub Organizations**: https://docs.github.com/en/organizations
- **GitHub Projects**: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- **Claude Code**: https://claude.ai/claude-code
- **Monorepo vs Multi-Repo**: See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

**Ready to explore enterprise agentic development!** 🚀
