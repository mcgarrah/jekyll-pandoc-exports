# Release Process

This document outlines the automated release process for jekyll-pandoc-exports.

## Visual Flow Diagram

See the complete [Release Process Flow Diagram](docs/release-flow-diagram.md) for a visual representation of all steps and decision points.

## Overview

The release process uses GitHub Actions with Trusted Publishers integration to RubyGems.org, providing a secure, automated workflow without API keys.

## Workflow

### 1. Development Branch Setup

```bash
# Create and switch to dev branch
git checkout -b dev
git push -u origin dev

# Set dev as default branch for development
# All feature work should be done on dev or feature branches
```

### 2. Making a Release

#### Option A: Using the Release Script (Recommended)

```bash
# Ensure you're on main branch and up to date
git checkout main
git pull origin main

# Run the release script
bin/release 1.1.0

# This will:
# - Update lib/jekyll-pandoc-exports/version.rb
# - Update CHANGELOG.md with new version entry
# - Run tests to ensure everything works
# - Commit changes and create/push tag
# - Trigger automated publishing
```

#### Option B: Manual Process

```bash
# 1. Update version in lib/jekyll-pandoc-exports/version.rb
# 2. Update CHANGELOG.md with new version entry
# 3. Commit changes
git add lib/jekyll-pandoc-exports/version.rb CHANGELOG.md
git commit -m "Bump version to 1.1.0"

# 4. Create and push tag
git tag v1.1.0
git push origin main
git push origin v1.1.0
```

### 3. Automated Publishing Flow

When a tag is pushed:

1. **Release Workflow** (`release.yml`) triggers:
   - Runs full test suite
   - Verifies version consistency
   - Extracts changelog for release notes
   - Creates GitHub Release with changelog
   - Builds gem file

2. **Publish Workflow** (`publish.yml`) triggers:
   - Uses Trusted Publishers to authenticate with RubyGems
   - Publishes gem to rubygems.org
   - No API keys required

## File Structure

```
.github/workflows/
├── ci.yml          # Continuous integration (tests on push/PR)
├── release.yml     # Creates GitHub releases and builds gems
└── publish.yml     # Publishes to RubyGems using Trusted Publishers

bin/
└── release         # Release management script

CHANGELOG.md        # Version history (required for releases)
lib/jekyll-pandoc-exports/
└── version.rb      # Version definition
```

## Trusted Publishers Configuration

The repository is configured with Trusted Publishers on RubyGems.org:

- **Repository**: `mcgarrah/jekyll-pandoc-exports`
- **Workflow**: `publish.yml`
- **Environment**: Not specified (any)

This allows secure publishing without storing API keys in GitHub secrets.

## CHANGELOG.md Format

The changelog follows [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

## [Unreleased]

## [1.1.0] - 2024-01-15

### Added
- New feature descriptions

### Changed
- Modified functionality descriptions

### Fixed
- Bug fix descriptions

## [1.0.0] - 2024-01-01
- Initial release
```

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

## Development Workflow

### Feature Development

```bash
# Start from dev branch
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/new-functionality
# ... make changes ...
git commit -m "Add new functionality"
git push origin feature/new-functionality

# Create PR to dev branch
# After review and approval, merge to dev
```

### Preparing for Release

```bash
# Merge dev to main when ready for release
git checkout main
git pull origin main
git merge dev
git push origin main

# Use release script or manual process above
bin/release 1.1.0
```

## Troubleshooting

### Version Mismatch Error

If the release workflow fails with version mismatch:

```bash
# Check current version in gemspec
ruby -e "spec = Gem::Specification.load('jekyll-pandoc-exports.gemspec'); puts spec.version"

# Update lib/jekyll-pandoc-exports/version.rb to match tag
# Or delete tag and recreate with correct version
```

### Missing Changelog Entry

If release fails due to missing changelog:

1. Add entry to CHANGELOG.md for the version
2. Commit the change
3. Delete and recreate the tag

### Trusted Publishers Issues

If RubyGems publishing fails:

1. Verify Trusted Publishers configuration on rubygems.org
2. Check that workflow name matches exactly: `publish.yml`
3. Ensure repository name is correct: `mcgarrah/jekyll-pandoc-exports`

## Authentication & Tokens

### Automatic Authentication

**No manual setup required!** The system uses built-in authentication:

#### GitHub Token (GITHUB_TOKEN)
- **Automatically provided** by GitHub Actions for every repository
- **Permissions**: Controlled by `permissions:` block in workflow files
- **Usage**: Creating releases, accessing repository data
- **Security**: Repository-scoped, expires after workflow completion
- **Setup**: None required - works out of the box

#### Trusted Publishers (RubyGems)
- **Authentication**: Uses OpenID Connect (OIDC) - no stored credentials
- **Permissions**: Controlled by `id-token: write` permission
- **Usage**: Publishing gems to rubygems.org
- **Security**: No long-lived API keys, fully auditable
- **Setup**: One-time configuration on rubygems.org (already done)

### What You DON'T Need

- ❌ Manual GITHUB_TOKEN creation
- ❌ RubyGems API keys
- ❌ Stored secrets or credentials
- ❌ Token rotation or management

### Workflow Permissions

Each workflow declares only the permissions it needs:

```yaml
# release.yml
permissions:
  contents: write    # Create releases and tags

# publish.yml  
permissions:
  id-token: write    # Trusted Publishers authentication
  contents: read     # Read repository content
```

## Security Notes

- **Zero stored credentials** - all authentication is automatic
- **Trusted Publishers** provide secure, auditable publishing via OIDC
- **Minimal permissions** - each workflow gets only what it needs
- **All releases tagged and traceable** with full audit trail
- **Automated testing** prevents broken releases
- **Modern security practices** - no API keys or long-lived tokens