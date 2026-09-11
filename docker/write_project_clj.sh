#!/bin/bash -Eeu

# Writes the /tmp/project.clj that the baked classpath is computed from.
#
# The clojure version is read from the base image rather than written down
# here. The base resolves the newest stable release when it is built and
# records it, so reading it is what keeps this image asking for the clojure
# that is actually present. A kata runs with no network, so a dependency this
# file names that the base did not prefetch could not be had.

readonly VERSIONS=$(cat /versions.json)
readonly REGEX='"clojure":"([0-9.]+)"'
if [[ ! ${VERSIONS} =~ ${REGEX} ]]; then
  echo "ERROR: /versions.json has no clojure property: ${VERSIONS}" >&2
  exit 1
fi
readonly CLOJURE_VERSION="${BASH_REMATCH[1]}"

cat > /tmp/project.clj <<EOF
(defproject hiker "0.0.1-SNAPSHOT"
  :description "Run clojure.test tests inside cyber-dojo"
  :dependencies [[org.clojure/clojure "${CLOJURE_VERSION}"]]
  :source-paths ["."])
EOF
