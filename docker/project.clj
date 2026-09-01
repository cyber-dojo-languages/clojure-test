; The classpath baked into this image is computed from this file, so it names
; the same dependencies as the start-point's own project.clj. The two are read
; at different times, this one when the image is built and that one by whoever
; reads it in a kata, and they have to agree about which jars exist here.
;
; The clojure version is named rather than asked for as "RELEASE", because
; "RELEASE" is whatever was published most recently, including a pre-release. It
; resolves at the time of writing to 1.13.0-alpha6, so a rebuild would prefetch
; that and leave the version the start-point asks for absent from the image. A
; kata runs with no network, so a dependency the image did not prefetch cannot
; be had.
(defproject hiker "0.0.1-SNAPSHOT"
  :description "Run clojure.test tests inside cyber-dojo"
  :dependencies [[org.clojure/clojure "1.12.4"]]
  :source-paths ["."])
