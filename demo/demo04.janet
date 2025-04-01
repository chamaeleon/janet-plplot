(import ../plplot/plplot :as pl)

(defn plot1 [plot-type]
  (def f0 1.0)
  (def freql (array/new-filled 101))
  (def ampl (array/new-filled 101))
  (def phase (array/new-filled 101))
  (def text ["Amplitude" "Phase shift"])
  (def symbols ["" "#(728)"])
  (def opt-array [pl/PL-LEGEND-LINE (bor pl/PL-LEGEND-LINE pl/PL-LEGEND-SYMBOL)])
  (def text-colors [2 3])
  (def line-colors [2 3])
  (def line-styles [1 1])
  (def line-widths [1.0 1.0])
  (def symbol-numbers [0 4])
  (def symbol-colors [0 3])
  (def symbol-scales [0.0 1.0])

  (pl/pladv 0)

  (each i (range 101)
    (put freql i (+ -2 (/ i 20)))
    (let [freq (math/pow 10 (get freql i))]
      (put ampl i (* 20 (math/log10 (/ 1 (math/sqrt (+ 1 (math/pow (/ freq f0) 2)))))))
      (put phase i (- (* (/ 180 math/pi) (math/atan (/ freq f0)))))))

  (pl/plvpor 0.15 0.85 0.1 0.9)
  (pl/plwind -2.0 3.0 -80.0 0.0)
  (pl/plcol0 1)
  (case plot-type
    0 (pl/plbox "bcnlst" 0.0 0 "bnstv" 0.0 0)
    1 (pl/plbox "bcfghlnst" 0.0 0 "bcghnstv" 0.0 0))
  (pl/plcol0 2)
  (pl/plline freql ampl)
  (pl/plcol0 2)
  (pl/plptex 1.6 -30.0 1.0 -20.0 0.5 "-20 dB/decade")
  (pl/plcol0 1)
  (pl/plmtex "b" 3.2 0.5 0.5 "Frequency")
  (pl/plmtex "t" 2.0 0.5 0.5 "Single Pole Low-Pass Filter")
  (pl/plcol0 2)
  (pl/plmtex "l" 5.0 0.5 0.5 "Amplitude (dB)")

  (var nlegend 1)
  
  (case plot-type
    0 (do (pl/plcol0 1)
          (pl/plwind -2.0 3.0 -100.0 0.0)
          (pl/plbox "" 0.0 0 "cmstv" 30.0 3)
          (pl/plcol0 3)
          (pl/plline freql phase)
          (pl/plstring freql phase "#(728)")
          (pl/plcol0 3)
          (pl/plmtex "r" 5.0 0.5 0.5 "Phase shift (degrees)")
          (set nlegend 2)))
  
  (pl/plscol0a 15 32 32 32 0.70)
  (pl/pllegend
   # opt
   (bor pl/PL-LEGEND-BACKGROUND pl/PL-LEGEND-BOUNDING-BOX)
   # position
   pl/PL-POSITION-RIGHT
   # x
   0.0
   # y
   0.0
   # plot_width
   0.1
   # bg_color
   15
   # bb_color
   15
   # bb_style
   1
   # nrow
   0
   # ncolumn
   0
   # opt_array
   opt-array
   # text_offset
   1.0
   # text_scale
   1.0
   # text_spacing
   2.0
   # text_justification
   0
   # text_colors
   text-colors
   # text
   text
   # box_colors
   []
   # box_patterns
   []
   # box_scales
   []
   # box_line_widths
   []
   # line_colors
   line-colors
   # line_styles
   line-styles
   # line_widths
   line-widths
   # symbol_colors
   symbol-colors
   # symbol_scales
   symbol-scales
   # symbol_numbers
   symbol-numbers
   # symbols
   symbols))

(pl/plparseopts (dyn :args))
(pl/plinit)
(pl/plfont 2)

(plot1 0)
(plot1 1)

(pl/plend)