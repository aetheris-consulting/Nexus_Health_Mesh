#!/bin/bash

# NEXUS Health Mesh - GitHub Push Script
# Run this AFTER creating an empty repository on GitHub.com

set -e  # Exit on error

echo "🚀 NEXUS GitHub Setup Script"
echo "=============================="
echo ""

# Check if repository name is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide your GitHub username"
    echo "Usage: ./push-to-github.sh YOUR_GITHUB_USERNAME"
    echo "Example: ./push-to-github.sh thomassmith"
    exit 1
fi

GITHUB_USERNAME=$1
REPO_NAME="nexus-health-mesh"
GITHUB_URL="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"

echo "📋 Configuration:"
echo "   GitHub User: $GITHUB_USERNAME"
echo "   Repository: $REPO_NAME"
echo "   Remote URL: $GITHUB_URL"
echo ""

# Confirm with user
read -p "Does this look correct? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 1
fi

echo ""
echo "⚠️  IMPORTANT: Make sure you have:"
echo "   1. Created an EMPTY repository called '$REPO_NAME' on GitHub"
echo "   2. Set up SSH keys (or use HTTPS with your token)"
echo ""
read -p "Ready to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 1
fi

# Navigate to the repository directory
cd nexus-health-mesh || {
    echo "❌ Error: nexus-health-mesh directory not found"
    echo "   Please extract the .tar.gz file first:"
    echo "   tar -xzf nexus-health-mesh-v0.1.0-academic.tar.gz"
    exit 1
}

echo ""
echo "🔧 Initializing git repository..."
git init

echo "📝 Adding files..."
git add .

echo "💾 Creating initial commit..."
git commit -m "Initial commit - v0.1.0 architecture specification

Complete technical specification for NEXUS Health Mesh:
- Federated AI coordination architecture (APIs + Events + Ledger)
- Observer sentinel specification (internal quality/safety watchdog)
- Multi-stakeholder consent management
- Cryptographic provenance model
- Research collaboration framework
- 2025-2029 roadmap

Prepared for University of Pittsburgh - Anthropic partnership proposal."

echo "🌿 Setting main branch..."
git branch -M main

echo "🔗 Adding remote origin..."
git remote add origin "$GITHUB_URL"

echo "⬆️  Pushing to GitHub..."
git push -u origin main

echo "🏷️  Creating release tag..."
git tag -a v0.1.0 -m "Initial architecture specification - Academic collaboration ready"
git push origin v0.1.0

echo ""
echo "✅ SUCCESS! Your repository is now on GitHub:"
echo "   https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo ""
echo "📋 Next steps:"
echo "   1. Visit your repository on GitHub"
echo "   2. Add topics: healthcare, ai, federated-learning, privacy, hipaa"
echo "   3. Create a release from the v0.1.0 tag"
echo "   4. Enable Issues and Discussions"
echo "   5. Email Johanna Bowman at Anthropic!"
echo ""
echo "🎉 You're ready to submit to Pitt-Anthropic partnership!"

