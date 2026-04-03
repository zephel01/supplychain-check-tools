#!/bin/bash

################################################################################
# Git Repository Setup Script
# サプライチェーン攻撃防止ツール用 Git初期化スクリプト
################################################################################

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Git Repository Setup${NC}"
echo -e "${BLUE}Supply Chain Security Check Tool${NC}"
echo -e "${BLUE}================================================${NC}\n"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git is not installed${NC}"
    echo "Install Git and try again"
    exit 1
fi

echo -e "${GREEN}✓ Git is installed${NC}"
echo "Git version: $(git --version)"

# Check if already a git repo
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠ Git repository already exists${NC}"
    read -p "Reinitialize? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping initialization"
        exit 0
    fi
fi

# Initialize repository
echo -e "\n${BLUE}Initializing Git repository...${NC}"
git init
git config user.name "Supply Chain Auditor"
git config user.email "audit@example.com"

# Verify .gitignore exists
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}⚠ .gitignore not found, creating...${NC}"
    # Create minimal .gitignore
    cat > .gitignore << 'EOF'
supply_chain_check_report_*.txt
*.log
.env
.env.local
.DS_Store
Thumbs.db
EOF
fi

echo -e "${GREEN}✓ .gitignore configured${NC}"

# Add files to git
echo -e "\n${BLUE}Adding files to repository...${NC}"
git add .gitignore
git add README.md
git add QUICKSTART.md
git add IMPLEMENTATION_GUIDE.md
git add 00-START-HERE.md
git add *.sh
git add *.ps1
git status

# Create initial commit
echo -e "\n${BLUE}Creating initial commit...${NC}"
git commit -m "Initial commit: Supply Chain Security Check Tool v1.0.0

- Windows PowerShell script
- macOS/Linux Bash script
- Raspberry Pi OS optimized script
- Comprehensive documentation
- MIT License"

echo -e "\n${GREEN}✓ Git repository initialized successfully${NC}\n"

# Display next steps
echo -e "${BLUE}Next steps:${NC}"
echo "1. Add remote repository:"
echo "   git remote add origin https://github.com/yourusername/repo.git"
echo ""
echo "2. Push to remote:"
echo "   git push -u origin main"
echo ""
echo "3. View commit:"
echo "   git log --oneline"
echo ""
echo "4. Configure signing (optional but recommended):"
echo "   git config --global commit.gpgsign true"
echo "   git config --global user.signingkey <your-key-id>"
echo ""

