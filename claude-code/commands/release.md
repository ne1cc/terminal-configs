---
argument-hint: [context]
description: Prepare project for production release with quality checks and version management
---

# Release Preparation Assistant

You are an expert software engineer focused on preparing clean, production-ready releases. Your task is to systematically prepare a project for release through comprehensive quality checks, version management, and git operations.

## User Context & Release Focus

**IMPORTANT**: The user has provided the following specific context to guide release preparation:

**User Context**: $ARGUMENTS

If user context is provided above, ensure that:
1. **Adjust release priorities** based on user-specified focus areas or constraints
2. **Consider special requirements** for this particular release (urgency, specific features, etc.)
3. **Adapt quality checks** if user context indicates specific areas of concern
4. **Reference user guidance** when making decisions about release scope and timing

## Release Protocol Overview

Execute these phases in strict order. **DO NOT SKIP STEPS** - each phase validates the previous work and ensures release quality.

## Phase 1: Pre-Release Validation

### 1.1 Project Assessment
```
<thinking>
Let me assess the current project:
- Project type (TypeScript/Next.js vs Python)
- Package manager (bun vs uv)
- Current version and version file location
- Git status and remote repository
- Build configuration and requirements
- Testing setup and requirements
- User context and any special release requirements
- Priority areas or constraints mentioned by user
- Appropriate release timing and scope based on context
</thinking>
```

### 1.2 Code Quality Checks

**For TypeScript/Next.js Projects:**
```bash
# Lint and fix issues
bun run lint
# or if script doesn't exist:
bunx eslint . --fix

# Format code
bun run format  
# or if script doesn't exist:
bunx prettier --write .

# Type checking
bunx tsc --noEmit
```

**For Python Projects:**
```bash
# Activate virtual environment
source .venv/bin/activate  # or ensure uv environment is active

# Format code
uv run ruff format .
# or: uv run black .

# Lint and fix
uv run ruff check . --fix

# Type checking
uv run mypy . || echo "Type checking completed with issues"
```

### 1.3 Build Verification

**For TypeScript/Next.js Projects:**
```bash
# Clean build
bun run build

# Verify build succeeded
if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed - address errors before release"
    exit 1
fi
```

**For Python Projects:**
```bash
# Install/update dependencies
uv sync

# Run basic import test
uv run python -c "import sys; print('✅ Python imports successful')"

# If FastAPI project, test basic startup
uv run python -c "from main import app; print('✅ Application imports successful')" 2>/dev/null || echo "⚠️ Application import test skipped"
```

### 1.4 Test Execution (if tests exist)

**TypeScript/Next.js:**
```bash
# Run tests if test script exists
if grep -q '"test"' package.json; then
    bun test
    if [ $? -ne 0 ]; then
        echo "❌ Tests failed - address issues before release"
        exit 1
    fi
fi
```

**Python:**
```bash
# Run tests if pytest is configured
if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml; then
    uv run pytest
    if [ $? -ne 0 ]; then
        echo "❌ Tests failed - address issues before release"
        exit 1
    fi
fi
```

## Phase 2: Version Management

### 2.1 Current Version Detection

**Determine version location and current value:**

**TypeScript/Next.js Projects:**
```bash
# Read current version from package.json
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Current version: $CURRENT_VERSION"
```

**Python Projects:**
```bash
# Check multiple possible version locations
if [ -f "pyproject.toml" ]; then
    CURRENT_VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
elif [ -f "setup.py" ]; then
    CURRENT_VERSION=$(python setup.py --version)
elif [ -f "src/__init__.py" ]; then
    CURRENT_VERSION=$(grep '__version__' src/__init__.py | sed 's/__version__ = "\(.*\)"/\1/')
else
    CURRENT_VERSION="0.1.0"  # Default for new projects
fi
echo "Current version: $CURRENT_VERSION"
```

### 2.2 Version Increment Strategy

**Semantic Versioning Rules:**
- **Patch (X.X.+1)**: Bug fixes, small improvements, no breaking changes
- **Minor (X.+1.0)**: New features, backward compatible
- **Major (+1.0.0)**: Breaking changes, major refactors

**Auto-detect increment type from git commits since last tag:**
```bash
# Get commits since last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
    COMMITS=$(git log $LAST_TAG..HEAD --oneline)
else
    COMMITS=$(git log --oneline)
fi

# Analyze commit messages for version increment
if echo "$COMMITS" | grep -E "^[a-f0-9]+ (feat!|fix!|BREAKING CHANGE)" > /dev/null; then
    INCREMENT_TYPE="major"
elif echo "$COMMITS" | grep -E "^[a-f0-9]+ feat:" > /dev/null; then
    INCREMENT_TYPE="minor"
else
    INCREMENT_TYPE="patch"
fi

echo "Detected increment type: $INCREMENT_TYPE based on commits"
```

### 2.3 Version Increment Execution

**Calculate new version:**
```bash
# Parse current version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Increment based on type
case $INCREMENT_TYPE in
    "major")
        NEW_VERSION="$((MAJOR + 1)).0.0"
        ;;
    "minor")
        NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
        ;;
    "patch")
        NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
        ;;
esac

echo "New version will be: $NEW_VERSION"
```

**Update version in files:**

**TypeScript/Next.js:**
```bash
# Update package.json version
npm version $NEW_VERSION --no-git-tag-version
```

**Python:**
```bash
# Update pyproject.toml
if [ -f "pyproject.toml" ]; then
    sed -i.bak "s/^version = \".*\"/version = \"$NEW_VERSION\"/" pyproject.toml
    rm pyproject.toml.bak
fi

# Update __init__.py if exists
if [ -f "src/__init__.py" ]; then
    sed -i.bak "s/__version__ = \".*\"/__version__ = \"$NEW_VERSION\"/" src/__init__.py
    rm src/__init__.py.bak
fi
```

## Phase 3: Git Operations

### 3.1 Commit Outstanding Changes

```bash
# Check for untracked or modified files
if ! git diff-index --quiet HEAD --; then
    echo "📝 Committing outstanding changes..."
    
    # Add all changes
    git add .
    
    # Create release preparation commit
    git commit -m "chore: prepare release v$NEW_VERSION
    
    - Run code quality checks and formatting
    - Fix linting issues
    - Update version to $NEW_VERSION
    - Verify build and tests pass"
    
    echo "✅ Changes committed"
else
    echo "✅ No outstanding changes to commit"
fi
```

### 3.2 Version Tag Creation

```bash
# Create annotated tag with release notes
echo "🏷️ Creating version tag v$NEW_VERSION..."

# Generate release notes from commits
if [ -n "$LAST_TAG" ]; then
    RELEASE_NOTES=$(git log $LAST_TAG..HEAD --pretty=format:"- %s" | head -10)
else
    RELEASE_NOTES=$(git log --pretty=format:"- %s" | head -5)
fi

# Create annotated tag
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION

Changes since last release:
$RELEASE_NOTES

Release prepared on: $(date)
Build verified: ✅
Tests passed: ✅
Quality checks: ✅"

echo "✅ Tag v$NEW_VERSION created"
```

### 3.3 Remote Repository Push

```bash
# Check if remote repository exists
if git remote | grep -q "origin"; then
    echo "🚀 Pushing to remote repository..."
    
    # Push commits
    git push origin $(git branch --show-current)
    
    # Push tags
    git push origin --tags
    
    echo "✅ Successfully pushed to remote repository"
    
    # Show remote URLs for verification
    echo "📍 Remote repository:"
    git remote -v | head -2
else
    echo "⚠️ No remote repository configured - skipping push"
    echo "💡 To add remote: git remote add origin <repository-url>"
fi
```

## Phase 4: Post-Release Verification

### 4.1 Release Summary

```bash
echo "
🎉 RELEASE COMPLETED SUCCESSFULLY

📊 Release Summary:
├── Previous Version: $CURRENT_VERSION
├── New Version: $NEW_VERSION  
├── Increment Type: $INCREMENT_TYPE
├── Tag Created: v$NEW_VERSION
├── Build Status: ✅ Verified
├── Tests Status: ✅ Passed
├── Quality Checks: ✅ Completed
└── Remote Push: ✅ Completed

🔗 Next Steps:
- Review release tag: git show v$NEW_VERSION
- Deploy to staging/production if configured
- Update documentation if needed
- Notify team of release

📋 Release Checklist:
[x] Code quality checks passed
[x] Build verification completed  
[x] Tests executed successfully
[x] Version incremented properly
[x] Changes committed to git
[x] Release tag created
[x] Changes pushed to remote
"
```

### 4.2 Rollback Instructions (if needed)

```bash
echo "
🔄 Rollback Instructions (if needed):

To undo this release:
1. Delete local tag: git tag -d v$NEW_VERSION
2. Delete remote tag: git push origin :refs/tags/v$NEW_VERSION  
3. Reset to previous commit: git reset --hard HEAD~1
4. Force push: git push --force-with-lease origin $(git branch --show-current)

⚠️ Only use rollback if serious issues discovered immediately after release
"
```

## Error Handling

**At each phase, if errors occur:**
1. **Stop immediately** - do not proceed to next phase
2. **Display clear error message** with suggested fix
3. **Provide specific commands** to resolve the issue
4. **Allow manual intervention** before retrying

**Common Issues & Fixes:**
- **Linting errors**: Fix code issues, run linter again
- **Build failures**: Check dependencies, fix syntax errors
- **Test failures**: Fix failing tests, verify all pass
- **Git conflicts**: Resolve conflicts, commit resolution
- **Remote push failures**: Check credentials, repository access

---

**Remember**: A release represents the current state of your project frozen in time. Every release should be deployable, testable, and revertible. Take time to ensure quality - rushing releases creates technical debt and deployment issues.
