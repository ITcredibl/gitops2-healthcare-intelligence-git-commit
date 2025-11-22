#!/usr/bin/env bash
set -euo pipefail

# GitOps 2.0 Healthcare Intelligence - Repository Cleanup Script
# Removes redundant files and organizes documentation

echo "🧹 Cleaning up GitOps 2.0 Healthcare Intelligence Repository..."
echo ""

# Backup old files
echo "📦 Creating backup of old files..."
mkdir -p .backup
mv README-old.md .backup/ 2>/dev/null || true
mv healthcare-demo-old.sh .backup/ 2>/dev/null || true

# Remove build artifacts
echo "🗑️  Removing build artifacts..."
rm -f services/payment-gateway/payment-gateway
rm -f services/auth-service/auth-service
rm -f coverage.out
rm -f compliance-report.json
rm -f risk-output.json
rm -f intelligent-bisect-report.json

# Clean Python cache
echo "🐍 Cleaning Python cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true
find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true

# Clean Go build cache (optional)
echo "�� Cleaning Go build cache..."
go clean -cache -modcache 2>/dev/null || true

# Remove unnecessary node modules
echo "📦 Cleaning node modules..."
rm -rf node_modules 2>/dev/null || true
rm -f package-lock.json 2>/dev/null || true

# Organize documentation
echo "📚 Organizing documentation..."
mkdir -p docs/archive 2>/dev/null || true

# List of core documentation files to keep in root
CORE_DOCS="README.md CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md LICENSE"

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📁 Repository structure:"
echo "   • Core docs in root: $(echo $CORE_DOCS | wc -w | xargs) files"
echo "   • Detailed docs in docs/: $(ls docs/*.md 2>/dev/null | wc -l | xargs) files"
echo "   • Backups in .backup/: $(ls .backup 2>/dev/null | wc -l | xargs) files"
echo ""
echo "🎯 Next steps:"
echo "   1. Review: git status"
echo "   2. Test: ./final-validation.sh"
echo "   3. Demo: ./healthcare-demo.sh"
echo "   4. Commit changes"
echo ""

