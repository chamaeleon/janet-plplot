(import ../plplot/plplot)

(plplot/plparseopts (dyn :args))
(plplot/plinit)

(def NPTS 2047)
(def delta (/ (* 2 math/pi) NPTS))
(def data @[])

(each i (range NPTS)
  (array/push data (math/sin (* i delta))))

(plplot/plcol0 1)
(plplot/plhist data -1.1 1.1 44 0)
(plplot/plcol0 2)
(plplot/pllab "#frValue" "#frFrequency" "#frPLplot Example 5 - Probability function of Oscillator")

(plplot/plend)