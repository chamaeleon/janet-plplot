(import ../plplot/plplot :as pl)

(def N 100)
(def xs @[])
(def ys @[])

(each i (range (inc N))
  (let [x (/ i N)
        y (* N x x)]
    (array/push xs x)
    (array/push ys y)))

(pl/plparseopts (dyn *args*))
# Specify a device here, or use the -dev command line optino
# (pl/plsdev "xcairo")
(pl/plinit)
(pl/plenv 0 1 0 N 0 0)
(pl/pllab "x" (string/format "y=%d x#u2#d" N) "Simple PLplot Demo")
(pl/plline xs ys)
(pl/plend)

# Display all available devices and the corresponding nice string
(let [[menustrs devstrs] (pl/plgDevs)]
  (each s (map (fn [a b] (string/format "%12s -- %s" a b)) devstrs menustrs)
    (printf "%s" s)))
