;; The workload the class-data archive is dumped from.
;;
;; The archive has to exist before any learner's kata does, so the classes it
;; records are clojure's and clojure.test's rather than any kata's, and it
;; speeds up whatever a learner writes. This is shaped like a real kata all the
;; same, a namespace and a test asserting against it, so that the same code
;; paths are the ones that load.
;;
;; Both namespaces are in this one file because a dump refuses a classpath
;; holding a non-empty directory, so the throwaway cannot be a pair of files in
;; a directory the way a kata's are. Nothing here calls System/exit, because a
;; JVM only writes an archive when it exits of its own accord.

(ns greeter)

(defn greeting
  "Answers the greeting the throwaway test asserts against."
  []
  (str "hello"))

(ns greeter-test
  (:require [clojure.test :refer :all]))

(deftest about-greeting
  (is (= "hello" (greeter/greeting))))

(run-tests 'greeter-test)
