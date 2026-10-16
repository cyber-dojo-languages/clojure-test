#!/bin/bash -Eeu

# Writes the /tmp/project.clj that the baked classpath is computed from, and
# records clojure.test in /versions.json.
#
# The clojure version is read from the base image rather than written down
# here. The base resolves the newest stable release when it is built and
# records it, so reading it is what keeps this image asking for the clojure
# that is actually present. A kata runs with no network, so a dependency this
# file names that the base did not prefetch could not be had.

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

readonly VERSIONS=$(cat /versions.json)
readonly REGEX='"language": *\{[^}]*"version": *"([0-9.]+)"'
if [[ ! ${VERSIONS} =~ ${REGEX} ]]; then
  echo "ERROR: /versions.json has no language version: ${VERSIONS}" >&2
  exit 1
fi
readonly CLOJURE_VERSION="${BASH_REMATCH[1]}"

cat > /tmp/project.clj <<EOF
(defproject hiker "0.0.1-SNAPSHOT"
  :description "Run clojure.test tests inside cyber-dojo"
  :dependencies [[org.clojure/clojure "${CLOJURE_VERSION}"]]
  :source-paths ["."])
EOF

# clojure.test ships inside clojure itself, so it has no version of its own.
add_test_framework clojure.test ''
cat /versions.json
