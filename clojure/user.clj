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

(reload/init {:dirs classpath
              :no-reload '#{user}})

(defn reload-namespaces []
  (reload/reload))

;; =============================================================================
;; Binding System
;; =============================================================================
;; Projects define bindings in deps.local.edn under :local/config :bindings
;; Example:
;; {:local/config
;;  {:bindings
;;   {:restart! my.project/reset
;;    :stop! my.project/stop}}}
;;
;; Or with multiple options (shows picker in nvim):
;; {:local/config
;;  {:bindings
;;   {:restart! [my.project/reset my.other/reset]}}}

(defn get-local-config []
  (let [file (io/file "deps.local.edn")]
    (when (.exists file)
      (some->> (slurp file)
               (edn/read-string)
               :local/config))))

(defn get-binding [binding-name]
  (get-in (get-local-config) [:bindings binding-name]))

(defn list-bindings
  "Returns a vector of symbols for the given binding name.
   Called from nvim to populate the picker."
  [binding-name]
  (if-let [sym (get-binding binding-name)]
    (if (vector? sym)
      sym
      [sym])
    []))

(def ^:dynamic b*
  "Holds the result of the last run-binding! call"
  nil)

(defn run-binding!
  "Runs a binding by name. If binding-sym is provided, runs that specific symbol.
   Otherwise, looks up the binding from deps.local.edn."
  ([binding-name] (run-binding! binding-name nil))
  ([binding-name binding-sym]
   (if-let [sym (if (symbol? binding-sym)
                  binding-sym
                  (get-binding binding-name))]
     (let [sym (if (vector? sym)
                 (first sym)
                 sym)]
       (if-let [f (requiring-resolve sym)]
         (let [_ (println (str "Running " sym))
               result (f)]
           (alter-var-root #'b* (constantly result)))
         (println (str "No " binding-name " var found"))))
     (println (str "No " binding-name " defined in :local/config :bindings")))
   nil))

;; =============================================================================
;; Legacy support - old functions that use the new binding system
;; =============================================================================
;; These check the new :local/config :bindings first, then fall back to
;; the old :aliases :local-dev format for backwards compatibility

(defonce local-dev* (atom nil))

(defn- load-legacy-alias []
  (or @local-dev*
      (let [file (io/file "deps.local.edn")]
        (when (.exists file)
          (some->> (slurp file)
                   (edn/read-string)
                   :aliases
                   :local-dev
                   (reset! local-dev*))))))

(defn reset-app! []
  (if-let [sym (get-binding :restart!)]
    (run-binding! :restart!)
    ;; Fallback to legacy format
    (if-let [sym (some-> (load-legacy-alias) :reset-fn)]
      (let [f (requiring-resolve sym)]
        (println (str "Running " f))
        (f))
      (println "No :restart! binding or :reset-fn defined"))))

(defn stop-app! []
  (if-let [sym (get-binding :stop!)]
    (run-binding! :stop!)
    ;; Fallback to legacy format
    (if-let [sym (some-> (load-legacy-alias) :stop-fn)]
      (let [f (requiring-resolve sym)]
        (println (str "Running " f))
        (f))
      (println "No :stop! binding or :stop-fn defined"))))

(println "Global user.clj loaded")
