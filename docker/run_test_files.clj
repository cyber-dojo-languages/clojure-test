;; Runs the test files named on the command line and exits 0 when they all pass
;; and 1 when they do not.
;;
;; The files are named by the glob in cyber-dojo.sh, so which files count as
;; tests is decided there rather than here. Nothing in this file knows the names
;; the start-point ships; a learner writes source and test files named for the
;; exercise they are doing, and those are what arrive here.
;;
;; Loading a test file loads the source file it requires, because the kata's
;; directory is on the classpath. Tests are then run in the namespaces those
;; files brought in, which is why the namespaces present beforehand are noted:
;; it keeps clojure's own namespaces out, and it keeps a source namespace that
;; holds no tests from being announced as though it were one.

(require 'clojure.test)

(defn- holds-tests?
  "Answers whether a namespace defines anything clojure.test would run."
  [namespace]
  (some (comp :test meta) (vals (ns-interns namespace))))

(def ^:private already-loaded
  "The namespaces that exist before any of the kata's files are loaded."
  (set (all-ns)))

(doseq [file *command-line-args*]
  (load-file file))

(let [loaded (remove already-loaded (all-ns))
      tested (sort-by ns-name (filter holds-tests? loaded))
      summary (apply clojure.test/run-tests tested)]
  (System/exit (if (clojure.test/successful? summary) 0 1)))
