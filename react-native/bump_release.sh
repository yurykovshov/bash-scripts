#!/bin/bash

# Set the path to your package.json file
PACKAGE_JSON_PATH="./package.json"

# Get the current version from package.json
CURRENT_VERSION=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' ${PACKAGE_JSON_PATH})

# Split the version into its parts
MAJOR=$(echo ${CURRENT_VERSION} | cut -d. -f1)
MINOR=$(echo ${CURRENT_VERSION} | cut -d. -f2)
PATCH=$(echo ${CURRENT_VERSION} | cut -d. -f3)

# Determine which part of the version to increment
if [ "$1" == "minor" ]; then
  NEW_MINOR=$((MINOR + 1))
  NEW_VERSION="${MAJOR}.${NEW_MINOR}.0"
elif [ "$1" == "patch" ]; then
  NEW_PATCH=$((PATCH + 1))
  NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"
else
  echo "Usage: $0 [minor|patch]"
  exit 1
fi

# Update the package.json file
sed -i '' "s/\"version\": \"${CURRENT_VERSION}\"/\"version\": \"${NEW_VERSION}\"/g" ${PACKAGE_JSON_PATH}

# Update the version in the iOS files
sed -i '' "s/MARKETING_VERSION = ${CURRENT_VERSION}/MARKETING_VERSION = ${NEW_VERSION}/g" ios/omyrun.xcodeproj/project.pbxproj

# Update the version in the Android files
sed -i '' "s/versionName \"${CURRENT_VERSION}\"/versionName \"${NEW_VERSION}\"/g" android/app/build.gradle

# Commit the changes
git add ${PACKAGE_JSON_PATH}
git add android/app/build.gradle
git add ios/omyrun.xcodeproj/project.pbxproj
git commit -m "Bump to version ${NEW_VERSION}"
git push
