# 🚀 Enhanced Release Workflow

## Overview

The release process is now fully automated with GitHub CLI integration. Two scripts handle the complete workflow:

- **`bin/release`** - Complete automated release process
- **`bin/reset-dev`** - Post-release dev branch preparation

## Prerequisites

```bash
# Install GitHub CLI
# macOS: brew install gh
# Ubuntu: sudo apt install gh

# Authenticate with GitHub
gh auth login

# Ensure you have push access to the repository
```

## 🎯 Complete Release Process for v0.15.1

### Step 1: Prepare Release (from dev branch)

```bash
# Ensure you're on dev branch with latest changes
git checkout dev
git pull origin dev
git status  # Should be clean

# Run the automated release script
./bin/release 0.15.1
```

**What this does automatically:**
1. ✅ Updates `lib/jekyll-pandoc-exports/version.rb` to 0.15.1
2. ✅ Moves [Unreleased] items to [0.15.1] in CHANGELOG.md
3. ✅ Runs full test suite (100% passing!)
4. ✅ Commits changes to dev branch
5. ✅ Pushes dev branch
6. ✅ Creates PR from dev to main using GitHub CLI
7. ✅ Auto-merges the PR
8. ✅ Switches to main branch
9. ✅ Creates and pushes release tag v0.15.1
10. ✅ Triggers GitHub Actions for publishing

### Step 2: Monitor Automated Publishing

```bash
# Watch GitHub Actions workflows
open https://github.com/mcgarrah/jekyll-pandoc-exports/actions

# Expected sequence:
# 1. release.yml triggers on tag push (3-5 min)
# 2. publish.yml triggers on GitHub release creation (1-2 min)
# 3. Read the Docs builds automatically (2-3 min)
```

### Step 3: Verify Release Success

```bash
# Check GitHub Release
open https://github.com/mcgarrah/jekyll-pandoc-exports/releases/tag/v0.15.1

# Check RubyGems publication
open https://rubygems.org/gems/jekyll-pandoc-exports

# Check Read the Docs site
open https://jekyll-pandoc-exports.readthedocs.io

# Test gem installation
gem install jekyll-pandoc-exports -v 0.15.1
```

### Step 4: Reset Dev Branch for Next Development

```bash
# Prepare dev branch for next development cycle
./bin/reset-dev
```

**What this does automatically:**
1. ✅ Switches to main and pulls latest changes
2. ✅ Rebases dev branch on latest main
3. ✅ Force pushes rebased dev branch
4. ✅ Shows current status
5. ✅ Suggests next version numbers

## 🛠️ Script Options

### Release Script Options

```bash
./bin/release --help                    # Show help
./bin/release 0.15.1                   # Full automated release
./bin/release 0.15.1 --skip-tests      # Skip tests (not recommended)
```

### Reset Dev Script Options

```bash
./bin/reset-dev --help                 # Show help
./bin/reset-dev                        # Reset dev branch
```

## 🔧 Manual Fallback (if GitHub CLI fails)

If the automated process fails, you can complete manually:

```bash
# After running ./bin/release 0.15.1 (it will show manual steps)
# 1. Create PR manually
gh pr create --base main --head dev --title "Release v0.15.1"

# 2. Merge PR
gh pr merge --merge --delete-branch=false

# 3. Create release tag
git checkout main && git pull origin main
git tag v0.15.1 && git push origin v0.15.1
```

## ⏱️ Expected Timeline

- **Release script execution**: 2-3 minutes
- **GitHub Actions (release.yml)**: 3-5 minutes
- **GitHub Actions (publish.yml)**: 1-2 minutes
- **Read the Docs build**: 2-3 minutes
- **Total end-to-end**: ~8-12 minutes

## 🎯 Version Numbering Guide

- **Patch (0.15.1 → 0.15.2)**: Bug fixes, documentation updates
- **Minor (0.15.1 → 0.16.0)**: New features, backwards compatible
- **Major (0.15.1 → 1.0.0)**: Breaking changes

## 🚨 Troubleshooting

### GitHub CLI Issues
```bash
# Check authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### Permission Issues
```bash
# Ensure you have push access to main branch
# Check repository settings → Branches → main → restrictions
```

### Test Failures
```bash
# Run tests manually to debug
bundle exec rake test

# Use --skip-tests only for documentation-only releases
./bin/release 0.15.1 --skip-tests
```

## 🎉 Success Indicators

✅ **Release Complete When:**
- GitHub Release created with changelog
- RubyGems shows new version
- Read the Docs site updated
- All GitHub Actions workflows green
- Dev branch reset and ready for next cycle

**The release process is now fully automated and bulletproof!** 🚀