#!/bin/bash

# Config
GITHUB_TOKEN=${GITHUB_TOKEN:-""}
ORG="sherwin-williams-co"
REPO="sai-facetube"
TEAM="gg-aad-dss-tagit-ebus-devops"
BRANCH="feat/update-codeowners-$(date +%Y%m%d-%H%M%S)"
WORK_DIR="temp_repo"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN not set"
    exit 1
fi

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "Cloning repository..."
git clone "https://${GITHUB_TOKEN}@github.com/${ORG}/${REPO}.git"
cd "$REPO"

echo "Configuring git..."
git config user.name "GitHub Actions"
git config user.email "actions@github.com"

echo "Creating branch: ${BRANCH}..."
git checkout -b "$BRANCH"

echo "Creating CODEOWNERS content..."
cat > CODEOWNERS << EOF
# Sherwin - Platform & Operations
* @${ORG}/${TEAM}

# Core files ownership
/CODEOWNERS @${ORG}/${TEAM}
/LICENSE @${ORG}/${TEAM}
/Jenkinsfile @${ORG}/${TEAM}
/Dockerfile @${ORG}/${TEAM}
/.dockerignore @${ORG}/${TEAM}

# GitHub specific files
/.github/ @${ORG}/${TEAM}
/.github/workflows/ @${ORG}/${TEAM}

# Configuration files
/.sherwin/ @${ORG}/${TEAM}
EOF

git add CODEOWNERS
git commit -m "Update CODEOWNERS to standard format"
git push -u origin "$BRANCH"

echo "Creating Pull Request..."
PR_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${ORG}/${REPO}/pulls" \
    -d "{
        \"title\": \"Update CODEOWNERS file to standard format\",
        \"body\": \"Standardize CODEOWNERS file format with required ownership definitions\",
        \"head\": \"${BRANCH}\",
        \"base\": \"main\"
    }")

if echo "$PR_RESPONSE" | grep -q "html_url"; then
    PR_URL=$(echo "$PR_RESPONSE" | jq -r .html_url)
    echo "✅ PR created successfully: $PR_URL"
else
    echo "❌ Failed to create PR. Error: $PR_RESPONSE"
fi

cd ../..
rm -rf "$WORK_DIR"
