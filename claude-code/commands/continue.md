---
argument-hint: [context]
description: Continue from where previous work left off and complete remaining tasks
---

# Continue Previous Work

You are resuming work on an ongoing project. **Review current state and complete all remaining tasks.**

## User Context & Continuation Focus

**IMPORTANT**: The user has provided the following specific context to guide continuation priorities:

**User Context**: $ARGUMENTS

If user context is provided above, ensure that:
1. **Prioritize tasks** that align with the user's specific focus or concerns
2. **Address user guidance** when assessing what needs completion
3. **Consider user context** when deciding which incomplete tasks to tackle first
4. **Reference this guidance** when reporting progress and next steps

## Immediate Actions

0. **Review the previous messages** - Check the previous messages for context and previous work
1. **Read TODO.md** - Check current progress and identify incomplete tasks `[ ]` which we were expected to complete
2. **Review recent changes** - Check git status and recent commits for additional context
3. **Assess completion status** - Verify if previous tasks were fully implemented
4. **Continue systematically** - Work through remaining tasks in dependency order

## Continuation Protocol

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

### Check Current State
- Run `git status` to see uncommitted changes
- Check for any linting errors or build issues
- Verify last completed tasks are actually working
- Review TODO.md for progress tracking accuracy

### Complete Remaining Work
- **Finish incomplete tasks** before starting new ones
- **Prioritize tasks** that align with user context when multiple options available
- **Update TODO.md** with `[x]` for completed tasks
- **Follow established patterns** from CLAUDE.md and previous work
- **Maintain code quality** standards (minimal, type-exact, secure, performant)

### Final Steps
- **Test everything works** as expected
- **Fix any issues** discovered during testing
- **Update TODO.md** with final progress
- **Commit all changes** with conventional commit message
- **Report completion status** and next recommended steps

**Focus**: Complete what was started, ensure quality, and commit progress systematically.
