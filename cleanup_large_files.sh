#!/bin/bash
set -e

# Threshold in bytes (50MB = 52428800 bytes)
THRESHOLD=52428800

echo "🔍 Scanning for files > 50MB in Git history..."
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  grep '^blob' | \
  awk -v limit=$THRESHOLD '$3 >= limit {print $2, $3, $4}' > large_files.txt

if [[ ! -s large_files.txt ]]; then
  echo "✅ No files over 50MB found."
  exit 0
fi

echo "⚠️ Large files found:"
cat large_files.txt

echo
echo "🗑 Removing large files from all commits..."
while read -r hash size path; do
  echo "   Removing: $path ($size bytes)"
  git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch \"$path\"" \
    --prune-empty --tag-name-filter cat -- --all
done < <(awk '{print $1, $2, $3}' large_files.txt)

echo
echo "🧹 Cleaning up Git history..."
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo
echo "🚫 Adding removed files to .gitignore..."
awk '{print $3}' large_files.txt >> .gitignore
sort -u .gitignore -o .gitignore

echo
echo "✅ Cleanup complete!"
echo "Now run the following to push changes to GitHub:"
echo "   git push origin main --force"
