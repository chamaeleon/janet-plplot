(import ../plplot/plplot :as pl)

(pl/plparseopts (dyn :args))
(pl/plinit)

(each kind-font (range 2)
  (pl/plfontld kind-font)
  (def maxfont (if (= kind-font 0) 1 4))
  (each font (range maxfont)
    (pl/plfont (inc font))
    (pl/pladv 0)
    (pl/plcol0 2)
    (pl/plvpor 0.1 1.0 0.1 0.9)
    (pl/plwind 0.0 1.0 0.0 1.3)
    (pl/plbox "bcg" 0.1 0 "bcg" 0.1 0)
    (pl/plcol0 15)
    (var k 0)
    (each i (range 13)
      (pl/plmtex "b" 1.5 (+ (* 0.1 i) 0.05) 0.5 (string/format "%d" (* i 10)))
      (each j (range 10)
        (def x (+ (* 0.1 j) 0.05))
        (def y (- 1.25 (* 0.1 i)))
        (if (< k 128)
          (pl/plpoin [x] [y] k))
        (set k (inc k))))
    (pl/plmtex "t" 1.5 0.5 0.5
               (if (= kind-font 0)
                 "PLplot Example 6 - plpoin symbols (compact)"
                 "PLplot Example 6 - plpoin symbols (extended)"))))

(pl/plend)