(import ../plplot/plplot :as pl)

# TODO: Add option table

(def pltex-mode false)

(pl/plparseopts (dyn :args))
(pl/plinit)
(pl/plfontld 0)

(def base [0 100 0 100 200 500 600 700 800 900
           2000 2100 2200 2300 2400 2500 2600 2700 2800 2900])

(each l (range 20)
  (if (= l 2)
    (pl/plfontld 1))
  (pl/pladv 0)
  (pl/plcol0 2)
  (pl/plvpor 0.15 0.95 0.1 0.9)
  (pl/plwind 0.0 1.0 0.0 1.0)
  (pl/plbox "bcg" 0.1 0 "bcg" 0.1 0)
  (pl/plcol0 15)
  (each i (range 10)
    (pl/plmtex "b" 1.5 (+ (* 0.1 i) 0.05) 0.5
               (string/format "%d" i)))
  (var k 0)
  (each i (range 10)
    (pl/plmtex "lv" 1.0 (- 0.95 (* 0.1 i)) 1.0
               (string/format "%d" (+ (get base l) (* 10 i))))
    (each j (range 10)
      (def x (+ (* 0.1 j) 0.05))
      (def y (- 0.95 (* 0.1 i)))
      (if pltex-mode
        (pl/plptex x y 1.0 0.0 0.5
                   (string/format "#(%d)" (+ (get base l) k)))
        (pl/plsym [x] [y] (+ (get base l) k)))
      (set k (inc k))))
  (pl/plmtex "t" 1.5 0.5 0.5
             (if (< l 2)
               "PLplot Example 7 - PLSYM symbols (compact)"
               "PLplot Example 7 - PLSYM symbols (extended)")))

(pl/plend)
