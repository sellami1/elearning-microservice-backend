#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if a commit message was provided as an argument
if [ -z "$1" ]; then
  echo "❌ Error: Commit message is required."
  echo "💡 Usage: ./gpush.sh \"Your commit message here\""
  exit 1
fi

# Store the commit message
COMMIT_MSG="$1"

echo "📦 Adding all changes..."
git add .

echo "📝 Committing with message: '$COMMIT_MSG'..."
git commit -m "$COMMIT_MSG"

echo "🚀 Pushing to origin k3s-deployed..."
git push origin k3s-deployed

echo "✅ Successfully pushed to k3s-deployed!"