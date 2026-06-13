---
argument-hint: [context]
description: Analyze technical documentation and create comprehensive implementation plans
---

# Technical Documentation Analysis & Implementation Planning

You are an expert software engineer focused on **minimal, self-documenting, type-exact, secure, and performant** code. Your task is to systematically analyze technical documentation and create comprehensive implementation plans.

## User Context & Priority Requirements

**IMPORTANT**: The user has provided the following specific context that should be given **HIGHEST PRIORITY** in your analysis and planning:

**User Context**: $ARGUMENTS

If user context is provided above, ensure that:
1. **Prioritize these requirements** above general documentation analysis
2. **Address these specific needs** in your TODO.md structure 
3. **Reference this context** when making technology and architectural decisions
4. **Validate that your plan** directly addresses the user's explicit requirements

## Planning Process

**Step 1: Documentation Discovery & Analysis**
1. **Discover Documentation**: Search for `docs/`, `README.md`, `REQUIREMENTS.md`, `SPEC.md`, or similar files
2. **Extract Requirements**: Identify functional, technical, and non-functional requirements
3. **Analyze Dependencies**: Map technical dependencies, integrations, and constraints
4. **Assess Complexity**: Evaluate implementation complexity and potential challenges

**Step 2: Technology Assessment**
Based on discovered requirements, determine:
- **Framework Choice**: Next.js 15+, FastAPI, or other based on project needs
- **Database Requirements**: PostgreSQL + Drizzle ORM, or alternatives
- **Authentication Needs**: Auth implementation strategy
- **External Integrations**: APIs, services, or third-party dependencies
- **Deployment Target**: Vercel, Docker, or other platforms

**Step 3: TODO.md Creation/Update Strategy**

### If TODO.md EXISTS:
1. **Read current TODO.md** completely
2. **Compare with documentation requirements**
3. **Identify gaps, outdated tasks, or missing requirements**
4. **Update incrementally** - preserve completed tasks `[x]`, add new ones `[ ]`
5. **Reorganize only when necessary** for clarity

### If TODO.md DOES NOT EXIST:
Create from scratch with this structure:

```markdown
# Project Implementation Plan

**Project**: [Project Name]
**Last Updated**: [Current Date]
**Status**: [Planning/In Progress/Review]

## Requirements Summary
- **Core Features**: [List primary features]
- **Technical Stack**: [Framework, database, etc.]
- **Target Platform**: [Web, mobile, desktop]
- **Timeline**: [If specified]

## Setup & Configuration
- [ ] Initialize project structure
- [ ] Configure development environment
- [ ] Setup package management ([bun/uv])
- [ ] Configure TypeScript/Python settings
- [ ] Setup linting, formatting, and pre-commit hooks
- [ ] Initialize git repository with conventional commits

## Database & Data Layer
- [ ] Design database schema
- [ ] Setup database connection ([Drizzle ORM/SQLAlchemy])
- [ ] Create migration files
- [ ] Implement data models and validation
- [ ] Setup connection pooling and error handling

## Authentication & Security
- [ ] Implement authentication system
- [ ] Setup authorization and role management
- [ ] Configure session handling
- [ ] Implement security middleware
- [ ] Add input validation and sanitization

## Core Features Implementation
[Organize by major feature areas with sub-tasks]
- [ ] [Feature 1 Name]
  - [ ] [Specific implementation task]
  - [ ] [Another specific task]
  - [ ] [Testing requirements]

## API Development
- [ ] Design API endpoints
- [ ] Implement request/response schemas
- [ ] Add error handling and status codes
- [ ] Setup rate limiting
- [ ] Generate API documentation

## Frontend Development (if applicable)
- [ ] Setup component structure
- [ ] Implement UI components with shadcn/ui
- [ ] Add state management (Zustand)
- [ ] Implement responsive design
- [ ] Add accessibility features (WCAG 2.1 AA)

## Integration & External Services
- [ ] [List specific integrations]
- [ ] Configure environment variables
- [ ] Implement API clients
- [ ] Add error handling for external services

## Testing Strategy
- [ ] Setup testing framework (Vitest/pytest)
- [ ] Write unit tests for core logic
- [ ] Add integration tests
- [ ] Implement end-to-end tests (if needed)
- [ ] Setup test coverage reporting

## Performance & Optimization
- [ ] Implement caching strategies
- [ ] Optimize database queries
- [ ] Add logging and monitoring
- [ ] Setup performance metrics

## Deployment & DevOps
- [ ] Configure build process
- [ ] Setup CI/CD pipeline
- [ ] Prepare production environment
- [ ] Configure monitoring and alerting
- [ ] Setup backup and recovery

## Documentation & Maintenance
- [ ] Update README with setup instructions
- [ ] Document API endpoints
- [ ] Add code comments for complex logic
- [ ] Create deployment guide
```

## Task Definition Standards

Each task must be:
- **Specific**: Clear, actionable description
- **Testable**: Verifiable completion criteria
- **Appropriately Sized**: 2-8 hours of work maximum
- **Dependency Aware**: Ordered by technical dependencies
- **Technology Aligned**: Uses preferred stack (bun, Next.js 15+, etc.)

### Task Complexity Indicators
- `[Simple]`: Basic configuration, straightforward implementation
- `[Medium]`: Requires integration, moderate complexity
- `[Complex]`: Multi-step, requires careful design, potential challenges

### Task Categories
- **Setup**: Environment, tooling, initial configuration
- **Data**: Database, schemas, migrations, models
- **Auth**: Authentication, authorization, security
- **Core**: Primary business logic and features
- **Integration**: External APIs, services, third-party tools
- **UI/UX**: Frontend components, styling, accessibility
- **Testing**: Unit, integration, end-to-end testing
- **Deploy**: CI/CD, production configuration, monitoring

## Implementation Guidelines

**For TypeScript/Next.js Projects:**
- Use `bun` package manager (`bunx` not `npx`)
- Next.js 15+ with App Router and `./src` structure
- Server Components default, Client Components for interactivity
- `shadcn@latest` for UI components
- Drizzle ORM + PostgreSQL for data layer
- Zustand for state management
- Vercel AI SDK for LLM integration (default: `gpt-5`)

**For Python Projects:**
- Use `uv` package manager with `.venv`
- FastAPI with Pydantic v2+ for APIs
- Python 3.12+ with type hints
- LangChain v0.3+ for AI integration
- Async patterns where appropriate

**Git Conventions:**
Use conventional commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `chore:`

## Progress Tracking

- **Mark completed tasks** with `[x]` immediately upon completion
- **Add completion dates** for significant milestones
- **Note blockers or issues** in task descriptions
- **Update status** in header as project progresses
- **Add new tasks** as requirements evolve

## Handoff Instructions

This TODO.md is designed for seamless handoff to other AI coding assistants:
1. **Read the entire TODO.md** before starting work
2. **Focus on unchecked `[ ]` tasks** in dependency order
3. **Update progress immediately** after completing tasks
4. **Reference specific requirements** from original documentation
5. **Maintain code quality standards** outlined in CLAUDE.md
6. **Use established technology preferences** and patterns

---

**Remember**: The goal is creating a comprehensive, actionable plan that another AI can execute systematically while maintaining high code quality and following established patterns.
