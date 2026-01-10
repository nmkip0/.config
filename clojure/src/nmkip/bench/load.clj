(ns nmkip.bench.load
  (:import
   [java.util.concurrent
    ExecutorService
    Executors
    TimeUnit
    TimeUnit]
   [java.util.concurrent.atomic AtomicLong]
   [org.HdrHistogram ConcurrentHistogram]))

(defn burn! [opts f]
  (let [concurrency (get opts :concurrency 1)
        pool (Executors/newFixedThreadPool concurrency)

        hist (ConcurrentHistogram. 3600000000 3)

        ops-remaining (when-let [samples (:samples opts)]
                        (AtomicLong. samples))
        total-succeeded (AtomicLong. 0)
        total-failed (AtomicLong. 0)

        stopped? (promise)
        runner (fn run-op! []
                 (while (and (not (realized? stopped?))
                             (if ops-remaining
                               (let [current (AtomicLong/.decrementAndGet ops-remaining)]
                                 (>= current 0))
                               true))
                   (let [t0 (System/nanoTime)]
                     (try (f)
                          (AtomicLong/.getAndIncrement total-succeeded)
                          (let [dt (- (System/nanoTime) t0)]
                            (.recordValue hist dt))
                          (catch InterruptedException _)
                          (catch Exception _
                            (AtomicLong/.getAndIncrement total-failed))))))

        warmups-remaining (when-let [samples (:warmup-samples opts)]
                            (AtomicLong. samples))
        warmup-stopped? (promise)
        warm-up-runner (fn run-op-warmup! []
                         (while (and (not (realized? warmup-stopped?))
                                     (if warmups-remaining
                                       (let [current (AtomicLong/.decrementAndGet warmups-remaining)]
                                         (< current 0))
                                       true))
                           (try (f)
                                (catch Exception _))))]

    (when (or (:warmup-samples opts)
              (:warmup-duration-ms opts))
      (let [tasks (mapv (fn [_]
                          (.submit pool ^Runnable warm-up-runner))
                        (range concurrency))]
        (when-let [duration-ms (:warmup-duration-ms opts)]
          (when-not (:warmup-samples opts)
            (Thread/sleep ^long duration-ms)
            (deliver warmup-stopped? true)
            (ExecutorService/.shutdownNow pool)))

        (mapv deref tasks)))

    (let [started-at (System/nanoTime)
          tasks (mapv (fn [_]
                        (.submit pool ^Runnable runner))
                      (range concurrency))]

      (when-let [duration-ms (get opts :duration-ms 10000)]
        (when-not (:samples opts)
          (Thread/sleep ^long duration-ms)
          (deliver stopped? true)
          (ExecutorService/.shutdownNow pool)))

      (mapv deref tasks)

      (let [ops-total (AtomicLong/.get total-succeeded)
            ops-failed (AtomicLong/.get total-failed)

            dx (- (System/nanoTime) started-at)
            dx-seconds (/ dx 1e9)

            ops-per-second (/ ops-total dx-seconds)

            n (.getTotalCount hist)
            ns->ms (fn [ns] (/ ns 1e6))
            p (fn [q] (ns->ms (.getValueAtPercentile hist q)))
            mean (if (pos? n) (ns->ms (long (/ (.getMean hist) 1))) 0.0)]

        (ExecutorService/.shutdownNow pool)
        (ExecutorService/.awaitTermination pool 1 TimeUnit/SECONDS)

        {:ops-per-second ops-per-second
         :runtime-seconds dx-seconds

         :ops-total ops-total
         :ops-failed ops-failed

         :mean mean
         :max (ns->ms (.getMaxValue hist))

         :p50 (p 50.0)
         :p95 (p 95.0)
         :p99 (p 99.0)}))))

(defmacro burn
  "Run a given function `f` with various constraints and calculate its performance.
  
   This is primarilly intended for load-testing external systems in a programmable way. This
   is **not** designed to benchmark clojure functions accurately - there are better tools
   for this (like criterium or JMH).
  
   This can be thought of more as programatic replacement to http loading tools like `hey`.
  
   This is useful when you want to have more complex load-generating scenarios, such as
   generating special data for each run.
  
   Accepts a few options:

   - `:concurrency` - Default: `1`. How many threads to spawn which concurrently call `f`
   - `:samples` - Default `nil`. How many times to call `f`. Total. Mutually exclusive with
                                 `:duration-ms`.
   - `:duration-ms` - Default `10000`. A duration in ms to execute `f`. Once duration is reached
                                       all threads will be shutdown. Mutually exclusive with
                                       `:samples`.
   - `:warmup-samples` - Default `nil`. Number of times to call `f` during warm-up phase. No metrics
                                        will be calculated during warm-up. Mutually exclusive with
                                        `:warmup-duration-ms`
   - `:warmup-duration-ms` - Default `nil`. Duration in ms to run the warm-up phase. Threads will be
                                            shutdown once this is reached. Mutually exclusive with
                                            `:warmup-samples`.

   ## Examples

   ```clojure
   (burn {:concurrency 10 :samples 100}
     (http/request client \"/some/path\"))

   (burn {:duration-ms 30000 :warmup-duration-ms 1000}
     (http/request client \"/some/path\"))

   (burn {:concurrency 10 :samples 1000 :warmup-samples 100}
     (http/request client \"/some/path\"))
   ```

   Reports results as a histogram, ops/s, total runtime, mean, max
   "
  {:style/indent :defn}
  [opts & body]
  `(burn! ~opts (fn [] ~@body)))
