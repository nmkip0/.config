(in-ns 'user)

(require '[clj-reload.core :as reload])
(require '[clojure.string :as str])
(require '[clojure.edn :as edn])
(require '[clojure.java.io :as io])

(def m2-dir
  (str (System/getenv "HOME") "/.m2"))

(def classpath
  (into #{}
        (comp
         (filter (fn [path]
                   (not (str/starts-with? path m2-dir))))
         (filter (fn [path]
                   (let [file (io/file path)]
                     (and (.exists file)
                          (.isDirectory file)))))
         (filter (fn [path]
                   (not (some #{path} #{"dev" "local"}))))
         (map (fn [path]
                (->> (java.io.File. path)
                     .getAbsolutePath
                     str))))

        (str/split (System/getProperty "java.class.path") #":")))

(reload/init {:dirs classpath})

(defn reload-namespaces []
  (reload/reload))

(defonce local-dev* (atom nil))

(defn load-alias []
  (or @local-dev*
      (some->> (slurp "deps.local.edn")
               (edn/read-string)
               :aliases
               :local-dev
               (reset! local-dev*))))

(defn reset-app! []
  (if-let [sym (some-> (load-alias) :reset-fn)]
    (let [f (requiring-resolve sym)]
      (println f)
      (f))
    (println "No reset-fn FQN is specified in local-dev alias")))

(defn stop-app! []
  (if-let [sym (some-> (load-alias) :stop-fn)]
    (let [f (requiring-resolve sym)]
      (println f)
      (f))
    (println "No stop-fn FQN is specified in local-dev alias")))

(println "Global user.clj loaded")
