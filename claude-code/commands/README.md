# Claude Code Custom Slash Commands

This directory contains custom slash commands for Claude Code that streamline common development workflows. Each command is designed to work systematically with your project's TODO.md file and follows established development patterns.

## Available Commands

| Command | Purpose | Context Support |
|---------|---------|----------------|
| [`/plan`](#plan) | Analyze documentation and create implementation plans | ✅ |
| [`/cook`](#cook) | Execute tasks from TODO.md systematically | ✅ |
| [`/continue`](#continue) | Resume and complete interrupted work | ✅ |
| [`/release`](#release) | Prepare project for production release | ✅ |
| [`/tech-dd`](#tech-dd) | Generate technical due diligence reports | ✅ |

---

## `/plan` - Technical Documentation Analysis & Implementation Planning

Creates comprehensive TODO.md implementation plans by analyzing project documentation and requirements.

### Frontmatter Configuration
```yaml
---
argument-hint: [context]
description: Analyze technical documentation and create comprehensive implementation plans
---
```

### Key Features
- **Documentation Discovery**: Automatically finds and analyzes `docs/`, `README.md`, `REQUIREMENTS.md`, `SPEC.md`
- **Technology Assessment**: Recommends appropriate tech stack based on project needs
- **Smart TODO.md Management**: Updates existing plans or creates new comprehensive roadmaps
- **Context-Aware Planning**: Prioritizes user-specified requirements

### Usage Examples

```bash
# Basic documentation analysis
/plan

# Focus on specific requirements
/plan "Building a real-time chat application with WebSocket support"

# Multiple context elements
/plan "E-commerce platform focusing on performance and security, targeting 100k users"

# Technical constraints
/plan "Legacy system integration with strict compliance requirements"
```

### What It Does
1. **Discovers** all project documentation and requirements
2. **Analyzes** functional, technical, and non-functional requirements
3. **Assesses** technology needs and architectural decisions
4. **Creates/Updates** TODO.md with structured implementation plan
5. **Prioritizes** user context requirements above general analysis

### Output Structure
- **Requirements Summary**: Core features, tech stack, platform, timeline
- **Setup & Configuration**: Environment, tooling, git setup
- **Database & Data Layer**: Schema, ORM, migrations, validation
- **Authentication & Security**: Auth system, authorization, middleware
- **Core Features**: Business logic organized by feature areas
- **Testing Strategy**: Unit, integration, end-to-end testing
- **Deployment & DevOps**: CI/CD, production environment, monitoring

---

## `/cook` - Implementation Execution Assistant

Systematically executes implementation tasks from an existing TODO.md file with focus on code quality and progress tracking.

### Frontmatter Configuration
```yaml
---
argument-hint: [context]
description: Execute implementation tasks from TODO.md with optional focus context
---
```

### Key Features
- **TODO.md-Driven Development**: Always reads and follows the implementation roadmap
- **Dependency-Aware Execution**: Respects task dependencies and logical progression
- **Context-Guided Priorities**: Adjusts task selection based on user focus areas
- **Quality Checkpoints**: Enforces code quality standards before task completion
- **Progress Tracking**: Updates TODO.md with completion timestamps and notes

### Usage Examples

```bash
# Basic task execution
/cook

# Focus on specific feature area
/cook "Focus on authentication and user management features"

# Prioritize performance-related tasks
/cook "Prioritize performance optimization and caching implementation"

# Work on specific technology integration
/cook "Focus on database setup and API development first"

# Address urgent requirements
/cook "Need to get the frontend working for demo tomorrow"
```

### What It Does
1. **Reads TODO.md** completely to understand current state and remaining tasks
2. **Assesses Progress** by checking completed `[x]` and pending `[ ]` tasks
3. **Selects Tasks** in dependency order, prioritizing user context when possible
4. **Implements Solutions** following established code quality standards
5. **Updates Progress** by marking tasks complete with timestamps
6. **Commits Changes** using conventional commit format

### Quality Standards (Non-Negotiable)
- **Minimal**: Write only necessary code, leverage existing libraries
- **Self-documenting**: Precise naming, single-responsibility functions
- **Type-exact**: Zero `any` types, comprehensive validation
- **Secure**: Input validation, proper auth, environment variables
- **Performant**: Follow framework optimization guides

### Technology Preferences
- **TypeScript/Next.js**: bun, Next.js 15+, App Router, shadcn@latest, Drizzle ORM, Zustand
- **Python**: uv, FastAPI, Pydantic v2+, Python 3.12+, LangChain v0.3+
- **AI Integration**: Vercel AI SDK with `gpt-5` default
- **Git**: Conventional commits (`feat:`, `fix:`, `docs:`, etc.)

---

## `/continue` - Work Continuation Assistant

Resumes interrupted development work by assessing current state and completing remaining tasks.

### Frontmatter Configuration
```yaml
---
argument-hint: [context]
description: Continue from where previous work left off and complete remaining tasks
---
```

### Key Features
- **State Assessment**: Reviews previous messages, TODO.md, and git status for context
- **Completion Verification**: Ensures previous tasks were actually finished properly
- **Context-Aware Resumption**: Prioritizes tasks based on user-specified focus areas
- **Quality Assurance**: Tests and validates existing work before proceeding
- **Clean Completion**: Commits all changes with proper conventional format

### Usage Examples

```bash
# Basic continuation
/continue

# Focus on specific incomplete area
/continue "Focus on finishing the authentication system - it was half implemented"

# Address specific issues
/continue "The build is failing, need to fix errors and get tests passing"

# Prioritize for deadlines
/continue "Need to complete the API endpoints for the demo tomorrow"

# Address technical debt
/continue "Focus on fixing linting errors and improving code quality"
```

### What It Does
1. **Reviews Context** from previous messages and conversation history
2. **Reads TODO.md** to identify incomplete tasks that were expected to be done
3. **Checks Git Status** for uncommitted changes and recent commits
4. **Assesses Completion** by verifying previous tasks were fully implemented
5. **Continues Systematically** through remaining tasks in dependency order
6. **Tests Everything** to ensure functionality works as expected
7. **Commits Changes** with proper conventional commit format

### Assessment Process
```
<thinking>
Let me assess the current state:
- What was the last completed task in TODO.md?
- Are there any incomplete implementations or half-finished work?
- What are the next priority tasks that need completion?
- Are there any build errors, linting issues, or broken functionality?
- How does the user context relate to what needs to be completed?
- Which tasks should be prioritized based on user guidance?
</thinking>
```

---

## `/release` - Release Preparation Assistant

Systematically prepares projects for production release through comprehensive quality checks, version management, and git operations.

### Frontmatter Configuration
```yaml
---
argument-hint: [context]
description: Prepare project for production release with quality checks and version management
---
```

### Key Features
- **4-Phase Release Process**: Pre-release validation, version management, git operations, post-release verification
- **Quality Gates**: Mandatory linting, build verification, and test execution
- **Semantic Versioning**: Auto-detects version increment type from git commit history
- **Multi-Technology Support**: Works with TypeScript/Next.js and Python projects
- **Automated Git Operations**: Commits changes, creates tags, pushes to remote
- **Context-Aware Preparation**: Adjusts release priorities based on user-specified focus areas

### Usage Examples

```bash
# Standard release preparation
/release

# Urgent hotfix release
/release "Urgent security patch - prioritize speed over extensive testing"

# Feature release with specific focus
/release "Major feature release - ensure all new API endpoints are thoroughly tested"

# Pre-demo release
/release "Demo preparation - focus on frontend stability and performance"

# Compliance-focused release
/release "Regulatory compliance release - extra attention to security and audit trails"
```

### Release Phases

#### **Phase 1: Pre-Release Validation**
- **Code Quality Checks**: Linting, formatting, type checking
- **Build Verification**: Ensures project builds without errors
- **Test Execution**: Runs all configured tests
- **Quality Gates**: Must pass before proceeding

#### **Phase 2: Version Management**
- **Current Version Detection**: Reads from package.json/pyproject.toml
- **Smart Increment**: Analyzes git commits for semantic versioning
  - `major`: Breaking changes (`feat!`, `fix!`, `BREAKING CHANGE`)
  - `minor`: New features (`feat:`)
  - `patch`: Bug fixes (`fix:`, other changes)
- **Version Update**: Updates version in appropriate project files

#### **Phase 3: Git Operations**
- **Commit Outstanding Changes**: Commits any untracked files
- **Create Release Tag**: Annotated tag with auto-generated release notes
- **Push to Remote**: Pushes commits and tags to origin repository

#### **Phase 4: Post-Release Verification**
- **Release Summary**: Complete overview of what was released
- **Rollback Instructions**: Emergency recovery steps if needed
- **Next Steps**: Deployment and notification guidance

### Technology Support

**TypeScript/Next.js Projects:**
```bash
bun run lint          # ESLint with auto-fix
bun run format        # Prettier formatting
bunx tsc --noEmit     # Type checking
bun run build         # Build verification
bun test              # Test execution (if configured)
npm version $VERSION  # Version update
```

**Python Projects:**
```bash
uv run ruff format .     # Code formatting
uv run ruff check . --fix # Linting
uv run mypy .            # Type checking
uv sync                  # Dependency sync
uv run pytest           # Test execution (if configured)
# Version update in pyproject.toml/__init__.py
```

---

## `/tech-dd` - Technical Due Diligence Assistant

Generates comprehensive technical due diligence reports using the specialized `tech-dd-analyst` subagent.

### Frontmatter Configuration
```yaml
---
argument-hint: [context]
description: Generate comprehensive technical due diligence report using specialized subagent
---
```

### Key Features
- **Subagent Integration**: Uses dedicated technical analysis subagent
- **Comprehensive Analysis**: Covers architecture, security, scalability, technical debt
- **Professional Reports**: Structured output suitable for stakeholders and decision-makers
- **Context-Guided Analysis**: Focuses on user-specified areas of concern or interest
- **Tailored Reporting**: Adjusts report depth based on specific use case and decision-making needs

### Usage Examples

```bash
# General technical assessment
/tech-dd

# Pre-acquisition analysis
/tech-dd "M&A due diligence - focus on scalability, technical debt, and integration challenges"

# Security-focused assessment
/tech-dd "Security audit required - prioritize vulnerability assessment and compliance gaps"

# Performance investigation
/tech-dd "Application performance issues - analyze bottlenecks and optimization opportunities"

# Architecture review
/tech-dd "Microservices migration planning - assess current architecture and modernization path"

# Investment decision support
/tech-dd "Funding round preparation - highlight technical strengths and address investor concerns"
```

### What It Does
1. **Activates** the `tech-dd-analyst` subagent with user context guidance
2. **Analyzes** codebase architecture, patterns, and technical decisions
3. **Evaluates** security posture, performance characteristics, and scalability
4. **Identifies** technical debt, risks, and improvement opportunities
5. **Generates** comprehensive report with findings and recommendations
6. **Tailors Analysis** to user-specified focus areas and decision-making context

### Analysis Areas
- **Architecture Assessment**: System design, patterns, scalability considerations
- **Security Evaluation**: Vulnerabilities, compliance, security best practices  
- **Technical Debt Analysis**: Code quality, maintainability, refactoring needs
- **Performance Review**: Bottlenecks, optimization opportunities, scalability limits
- **Risk Assessment**: Technical risks, dependencies, operational concerns
- **Recommendations**: Actionable improvements and strategic technical decisions

---

## Command Workflow Integration

These commands are designed to work together in a systematic development workflow:

### **Planning → Implementation → Continuation → Release**

1. **Start with `/plan`** to analyze requirements and create TODO.md
2. **Use `/cook`** to systematically implement tasks from the plan
3. **Use `/continue`** when work is interrupted or needs completion
4. **Use `/release`** when ready to prepare for production deployment
5. **Use `/tech-dd`** for comprehensive technical analysis when needed

### **Best Practices**

- **Always maintain TODO.md**: All commands rely on and update this central roadmap
- **Use context arguments**: Provide specific guidance to focus AI efforts
- **Follow conventional commits**: All commands use standardized git commit formats
- **Respect dependencies**: Commands understand and follow task prerequisite chains
- **Quality first**: All commands enforce established code quality standards

### **File Dependencies**

- **`TODO.md`**: Central implementation roadmap (created/updated by `/plan`, used by `/cook` and `/continue`)
- **`CLAUDE.md`**: Code quality standards and technology preferences
- **`.env.example`**: Environment variable templates
- **`package.json`/`pyproject.toml`**: Project dependencies and version information

---

## Installation & Usage

These commands are automatically available when placed in the `.claude/commands/` directory. Use them directly in Claude Code interactive sessions:

```bash
# List all available commands
/help

# Use commands with context
/plan "Focus on building a REST API with authentication"
/cook "Prioritize database setup and user management"
/continue "Fix the failing tests and complete API documentation"
/release
/tech-dd
```

**Pro Tip**: Use context arguments to guide AI focus and get more targeted results that align with your immediate priorities and constraints.
