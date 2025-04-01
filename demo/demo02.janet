(import ../plplot/plplot :as pl)

(defn draw-windows [nw cmap0-offset]
  (pl/plschr 0.0 3.5)
  (pl/plfont 4)
  (each i (range nw)
    (pl/plcol0 (+ i cmap0-offset))
    (pl/pladv 0)
    (var vmin 0.1)
    (var vmax 0.9)
    (each j (range 3)
      (pl/plwidth (inc j))
      (pl/plvpor vmin vmax vmin vmax)
      (pl/plwind 0.0 1.0 0.0 1.0)
      (pl/plbox "bc" 0.0 0 "bc" 0.0 0)
      (set vmin (+ vmin 0.1))
      (set vmax (- vmax 0.1)))
    (pl/plwidth 1)
    (pl/plptex 0.5 0.5 1.0 0.0 0.5 (string i))))

(defn demo1 []
  (pl/plbop)
  (pl/plssub 4 4)
  (draw-windows 16 0)
  (pl/pleop))

(defn demo2 []
  (def r (array/new-filled 116))
  (def g (array/new-filled 116))
  (def b (array/new-filled 116))
  (def lmin 0.15)
  (def lmax 0.85)
  (pl/plbop)
  (pl/plssub 10 10)
  (each i (range 100)
    (def h (* (/ 360 10) (mod i 10)))
    (def l (+ lmin (/ (* (- lmax lmin) (/ i 10)) 9)))
    (def s 1)
    (let [{:r r1 :g g1 :b b1} (pl/plhlsrgb h l s)]
      (put r (+ i 16) (* r1 255.001))
      (put g (+ i 16) (* g1 255.001))
      (put b (+ i 16) (* b1 255.001))))
  (each i (range 16)
    (let [{:r r2 :g g2 :b b2} (pl/plgcol0 i)]
      (put r i r2)
      (put g i g2)
      (put b i b2)))
  (pl/plscmap0 r g b)
  (draw-windows 100 16)
  (pl/pleop))

(pl/plparseopts (dyn :args))
(pl/plinit)

(demo1)
(demo2)

(pl/plend)
