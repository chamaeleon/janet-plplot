(import ../plplot/plplot :as pl)

(def x0 (array/new-filled 361))
(def y0 (array/new-filled 361))
(def x (array/new-filled 361))
(def y (array/new-filled 361))

(def dtr (/ math/pi 180))

(each i (range 361)
  (put x0 i (math/cos (* dtr i)))
  (put y0 i (math/sin (* dtr i))))

(pl/plparseopts (dyn :args))
(pl/plsori 1)
(pl/plinit)
(pl/plenv -1.3 1.3 -1.3 1.3 1 -2)

(each i (range 11)
  (pl/plarc 0.0 0.0 (* i 0.1) (* i 0.1) 0.0 360.0 0.0 0))

(pl/plcol0 2)

(each i (range 12)
  (def theta (* i 30))
  (def text (string/format "%d" (math/floor theta)))
  (def dx (math/cos (* dtr theta)))
  (def dy (math/sin (* dtr theta)))
  (pl/pljoin 0.0 0.0 dx dy)
  (def offset
    (cond (< theta 9.99) 0.45
          (< theta 99.9) 0.30
          true 0.15))
  (if (>= dx -0.00001)
    (pl/plptex dx dy dx dy (- offset) text)
    (pl/plptex dx dy (- dx) (- dy) (+ 1.0 offset) text)))

(each i (range 361)
  (def r (math/sin (* dtr 5 i)))
  (put x i (* (get x0 i) r))
  (put y i (* (get y0 i) r)))

(pl/plcol0 3)
(pl/plline x y)
(pl/plcol0 4)
(pl/plmtex "t" 2.0 0.5 0.5 "#frPLplot Example 3 - r(#gh)=sin 5#gh")

(pl/plend)