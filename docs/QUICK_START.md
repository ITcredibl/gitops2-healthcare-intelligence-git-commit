# GitOps 2.0 Healthcare Intelligence - Quick Start Guide

**Get started in 10 minutes!**

---

## Overview

This guide gets you up and running with the GitOps 2.0 Healthcare Intelligence Platform in just 10 minutes.

---

## Step 1: Prerequisites (2 minutes)

### Install Required Tools
```bash
# macOS
brew install go python3 git opa jq

# Ubuntu/Debian  
sudo apt-get install golang python3 git jq
# Install OPA from: https://www.openpolicyagent.org/docs/latest/#1-download-opa

# Verify installations
go version        # Should be 1.22+
python3 --version # Should be 3.10+
opa version       # Should be 0.50+
jq --version      # Should be 1.6+
```

---

## Step 2: Clone & Validate (3 minutes)

```bash
# Clone repository
git clone https://github.com/ITcredibl/gitops2-healthcare-intelligence.git
cd gitops2-healthcare-intelligence

# Run validation (takes ~2 minutes)
./final-validation.sh

# Expected output: 20/20 tests passing ✅
```

---

## Step 3: Run the Demo (5 minutes)

```bash
# Start the healthcare demo
./healthcare-demo.sh

# This demonstrates:
# ✅ Environment validation
# ✅ Policy enforcement (HIPAA/FDA/SOX)
# ✅ AI risk assessment
# ✅ Commit generation
# ✅ Service testing
# ✅ AI forensics
# ✅ Compliance monitoring
# ✅ Business impact ($800K savings)
```

---

## Step 4: Generate Your First Commit (2 minutes)

```bash
# Install git aliases
./setup-git-aliases.sh

# Generate a healthcare-compliant commit
git healthcare --type feat --scope payment \
  --description "implement automated invoice processing"

# Or use Python tool directly
python3 tools/healthcare_commit_generator.py \
  --type security \
  --scope phi \
  --description "implement patient data encryption" \
  --files "services/phi-service/encryption.go"
```

---

## What You Just Accomplished

✅ **Validated** a production-ready healthcare compliance platform  
✅ **Demonstrated** $800K/year cost savings through automation  
✅ **Generated** your first HIPAA/FDA/SOX compliant commit  
✅ **Experienced** AI-native engineering workflows  

---

## Next Steps

### For Developers
1. **Explore Services**
   ```bash
   cd services/payment-gateway
   go test ./... -cover
   make run
   ```

2. **Try AI Tools**
   ```bash
   python3 tools/git_intel/risk_scorer.py --json
   python3 tools/ai_compliance_framework.py analyze-commit HEAD --json
   ```

3. **Test Policies**
   ```bash
   opa test policies/ --verbose
   ```

### For Teams
1. **Set Up CI/CD**
   - Review `.github/workflows/risk-adaptive-ci.yml`
   - Integrate with your GitHub Actions
   - Configure compliance scanning

2. **Configure Copilot**
   - Read `.copilot/README-VSCODE-INTEGRATION.md`
   - Install VS Code extension
   - Start using AI-powered commits

3. **Measure ROI**
   - Track compliance time savings
   - Monitor deployment frequency
   - Report business impact

### For Enterprises
1. **Deploy to Production**
   ```bash
   ./setup-healthcare-enterprise.sh
   ```

2. **Review Documentation**
   - [Deployment Guide](DEPLOYMENT_GUIDE.md)
   - [Executive Overview](EXECUTIVE_OVERVIEW.md)
   - [Implementation Details](IMPLEMENTATION_UPDATE.md)

3. **Scale Across Teams**
   - Onboard 2-3 teams/week
   - Measure and optimize
   - Share success stories

---

## Common Commands

```bash
# Validation
./final-validation.sh           # Test everything
./healthcare-demo.sh            # Run demo
./cleanup-repo.sh               # Clean build artifacts

# AI Tools  
git risk --max-commits 20       # Risk assessment
git comply analyze-commit HEAD  # Compliance check
git healthcare --help           # Commit generator

# Services
cd services/payment-gateway && go test ./...
cd services/auth-service && go test ./...

# Policies
opa test policies/ --verbose

# Monitoring
python3 tools/compliance_monitor.py
```

---

## Troubleshooting

### Issue: Tests Failing
```bash
# Check prerequisites
go version
python3 --version
opa version

# Update if needed
brew upgrade go python3 opa
```

### Issue: Services Won't Build
```bash
# Update dependencies
cd services/payment-gateway
go mod tidy
go build
```

### Issue: Git Aliases Not Working
```bash
# Reinstall
./setup-git-aliases.sh

# Verify
git config --global --list | grep alias
```

---

## Getting Help

- **Documentation**: Check `docs/` folder
- **GitHub Issues**: Report bugs and request features
- **Community**: Join discussions
- **Demo**: Re-run `./healthcare-demo.sh` anytime

---

## Success Checklist

- [ ] Prerequisites installed
- [ ] Repository cloned
- [ ] Validation passing (20/20 tests)
- [ ] Demo completed successfully
- [ ] First commit generated
- [ ] Git aliases installed
- [ ] Ready to deploy!

---

**Congratulations!** 🎉

You've successfully set up the world's first AI-native healthcare compliance platform.

**Next:** Review [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for enterprise deployment.

---

*Quick Start Guide | Version 2.0.0 | Last Updated: November 21, 2025*
