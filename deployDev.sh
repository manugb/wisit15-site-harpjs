#!/bin/bash

echo "Starting deployment"
TEMP_DIRECTORY="/tmp/__temp_static_content"
CURRENT_COMMIT=`git rev-parse HEAD`
ORIGIN_URL="github.com/uqbar-project/wisit15-site-harpjs.git"
ORIGIN_URL_WITH_CREDENTIALS="https://${GITHUB_TOKEN}@${ORIGIN_URL}"

echo "Compiling site into " ${TEMP_DIRECTORY}
mkdir ${TEMP_DIRECTORY}
harp compile -o ${TEMP_DIRECTORY} || exit 1

echo "Tuning .gitinore files to select which files to push into gh-pages"
cp .gitignore ${TEMP_DIRECTORY}

# Ignore .gitignore itself
echo .gitignore >> ${TEMP_DIRECTORY}/.gitignore

# Do not ignore generated files in /assets
rm ${TEMP_DIRECTORY}/assets/.gitignore

echo "Pushing into " ${ORIGIN_URL}
cd ${TEMP_DIRECTORY}
echo "## Autogenerated site for Uqbar Project" > Readme.md

git init
git config user.name "Travis-CI" || exit 1
git config user.email "travis@uqbar-project.com" || exit 1
git checkout -b gh-pages
git add --all
git commit --allow-empty -m "Generated static site for $CURRENT_COMMIT" || exit 1
git remote add origin "$ORIGIN_URL_WITH_CREDENTIALS"
git push -u --force origin gh-pages

echo "Cleaning up temp files"
rm -Rf ${TEMP_DIRECTORY}

echo "Deployed successfully."
exit 0