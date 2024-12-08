npm version patch -no-git-tag-version
echo "Version=$(npm view . version)" >> $GITHUB_ENV
