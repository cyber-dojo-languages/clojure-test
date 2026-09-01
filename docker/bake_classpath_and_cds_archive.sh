#!/bin/bash -e

# Bakes the classpath a kata's test run uses, and dumps the class-data archive
# that run replays.
#
# A kata runs in a container that is thrown away afterwards, so its JVM loads
# clojure's several thousand classes from the jars every single time. An archive
# holds those classes in the form the JVM wants them, and replaying one costs a
# fraction of loading them again.
#
# The classpath is baked because working it out is lein's job and lein is not
# worth starting to do it: asking lein costs more than the whole test run does.
# Both files are read by cyber-dojo.sh.

readonly CLASSPATH_FILE=/.classpath
readonly ARCHIVE=/.clojure.jsa

cd /tmp

# Only the dependency jars are kept. lein also reports the project's own
# directories, and those name the directory this image is built in rather than
# the directory a kata runs in, which cyber-dojo.sh appends for itself. The
# paths are rewritten to /.m2, where the jars actually are, because lein reports
# them through root's home and a kata runs as the sandbox user.
lein classpath \
  | tr ':' '\n' \
  | grep '\.m2/' \
  | sed 's|^/root/\.m2/|/.m2/|' \
  | paste --serial --delimiters=: - \
  > "${CLASSPATH_FILE}"

# Dumped against exactly these jars and nothing else, because a dump refuses a
# classpath holding a non-empty directory and a kata's directory is one. A JVM
# replaying an archive accepts a classpath beginning with the one the archive
# was dumped from, which is why cyber-dojo.sh appends the kata's directory after
# these jars rather than before them.
java -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -XX:ArchiveClassesAtExit="${ARCHIVE}" \
  -cp "$(cat ${CLASSPATH_FILE})" \
  clojure.main /tmp/throwaway_kata.clj

# The sandbox user reads both of these at run time and owns neither.
chmod 0644 "${CLASSPATH_FILE}" "${ARCHIVE}"

cat "${CLASSPATH_FILE}"
ls --format=long "${CLASSPATH_FILE}" "${ARCHIVE}"
