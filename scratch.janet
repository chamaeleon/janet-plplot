(import ./plplot/plplot :as pl)

(pl/plparseopts (dyn :args))
(pl/plsdev "xcairo")
(pl/plinit)

# (plplot/plenv 0 100 0 100 0 0)

(printf "Version: %s" (pl/plgver))
(printf "Driver:  %s" (pl/plgdev))

# (plplot/plptex 50 50 0 0 0 "Hello")

# (plplot/plend)

(printf "%m" (pl/strings-buf ["a" "b"]))