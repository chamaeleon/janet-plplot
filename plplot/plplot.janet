#
# Load PLplot library
#

(def- plplot-library (ffi/native "libplplot.so.17"))

(def callback (delay (ffi/trampoline :default)))

(defn double-buf [doubles]
  (let [buf (buffer/new (length doubles))]
    (each n doubles (buffer/push-float64 buf :le n))
    buf))

(defn double-matrix-buf [doubles]
  (let [buf (buffer/new (length doubles))]
    (eachp [i row] doubles (ffi/write :ptr (double-buf row) buf (* i (ffi/size :ptr))))
    buf))

(defn int32-buf [int32s]
  (let [buf (buffer/new (length int32s))]
    (each n int32s (buffer/push-uint32 buf :le (math/floor n)))
    buf))

(defn strings-buf [strings]
  (let [buf (buffer/new (* (ffi/size :ptr) (length strings)))]
    (eachp [i s] strings
      (ffi/write :ptr s buf (* i (ffi/size :ptr))))
    buf))

#
# Constant values
# 

# Switches for escape function call.
# Some of these are obsolete but are retained in order to process
# old metafiles
(def PLESC-SET-RGB                   1)   # obsolete
(def PLESC-ALLOC-NCOL                2)   # obsolete
(def PLESC-SET-LPB                   3)   # obsolete
(def PLESC-EXPOSE                    4)   # handle window expose
(def PLESC-RESIZE                    5)   # handle window resize
(def PLESC-REDRAW                    6)   # handle window redraw
(def PLESC-TEXT                      7)   # switch to text screen
(def PLESC-GRAPH                     8)   # switch to graphics screen
(def PLESC-FILL                      9)   # fill polygon
(def PLESC-DI                        10)  # handle DI command
(def PLESC-FLUSH                     11)  # flush output
(def PLESC-EH                        12)  # handle Window events
(def PLESC-GETC                      13)  # get cursor position
(def PLESC-SWIN                      14)  # set window parameters
(def PLESC-DOUBLEBUFFERING           15)  # configure double buffering
(def PLESC-XORMOD                    16)  # set xor mode
(def PLESC-SET-COMPRESSION           17)  # AFR: set compression
(def PLESC-CLEAR                     18)  # RL: clear graphics region
(def PLESC-DASH                      19)  # RL: draw dashed line
(def PLESC-HAS-TEXT                  20)  # driver draws text
(def PLESC-IMAGE                     21)  # handle image
(def PLESC-IMAGEOPS                  22)  # plimage related operations
(def PLESC-PL2DEVCOL                 23)  # convert PLColor to device color
(def PLESC-DEV2PLCOL                 24)  # convert device color to PLColor
(def PLESC-SETBGFG                   25)  # set BG, FG colors
(def PLESC-DEVINIT                   26)  # alternate device initialization
(def PLESC-GETBACKEND                27)  # get used backend of (wxWidgets) driver - no longer used
(def PLESC-BEGIN-TEXT                28)  # get ready to draw a line of text
(def PLESC-TEXT-CHAR                 29)  # render a character of text
(def PLESC-CONTROL-CHAR              30)  # handle a text control character (super/subscript, etc.)
(def PLESC-END-TEXT                  31)  # finish a drawing a line of text
(def PLESC-START-RASTERIZE           32)  # start rasterized rendering
(def PLESC-END-RASTERIZE             33)  # end rasterized rendering
(def PLESC-ARC                       34)  # render an arc
(def PLESC-GRADIENT                  35)  # render a gradient
(def PLESC-MODESET                   36)  # set drawing mode
(def PLESC-MODEGET                   37)  # get drawing mode
(def PLESC-FIXASPECT                 38)  # set or unset fixing the aspect ratio of the plot
(def PLESC-IMPORT-BUFFER             39)  # set the contents of the buffer to a specified byte string
(def PLESC-APPEND-BUFFER             40)  # append the given byte string to the buffer
(def PLESC-FLUSH-REMAINING-BUFFER    41)  # flush the remaining buffer e.g. after new data was appended

# Alternative unicode text handling control characters
(def PLTEXT-FONTCHANGE               0)  # font change in the text stream
(def PLTEXT-SUPERSCRIPT              1)  # superscript in the text stream
(def PLTEXT-SUBSCRIPT                2)  # subscript in the text stream
(def PLTEXT-BACKCHAR                 3)  # back-char in the text stream
(def PLTEXT-OVERLINE                 4)  # toggle overline in the text stream
(def PLTEXT-UNDERLINE                5)  # toggle underline in the text stream

# image operations
(def ZEROW2B                         1)
(def ZEROW2D                         2)
(def ONEW2B                          3)
(def ONEW2D                          4)

# Window parameter tags
(def PLSWIN-DEVICE    1)               # device coordinates
(def PLSWIN-WORLD     2)               # world coordinates

# Axis label tags
(def PL-X-AXIS        1)               # The x-axis
(def PL-Y-AXIS        2)               # The y-axis
(def PL-Z-AXIS        3)               # The z-axis

# PLplot Option table & support constants

# Option-specific settings
(def PL-OPT-ENABLED      0x0001)       # Obsolete
(def PL-OPT-ARG          0x0002)       # Option has an argument
(def PL-OPT-NODELETE     0x0004)       # Don't delete after processing
(def PL-OPT-INVISIBLE    0x0008)       # Make invisible
(def PL-OPT-DISABLED     0x0010)       # Processing is disabled

# Option-processing settings -- mutually exclusive
(def PL-OPT-FUNC      0x0100)          # Call handler function
(def PL-OPT-BOOL      0x0200)          # Set *var = 1
(def PL-OPT-INT       0x0400)          # Set *var = atoi(optarg)
(def PL-OPT-FLOAT     0x0800)          # Set *var = atof(optarg)
(def PL-OPT-STRING    0x1000)          # Set var = optarg

# Global mode settings 
# These override per-option settings

# Command line parse options
(def PL-PARSE-PARTIAL                0x0000) # For backward compatibility
(def PL-PARSE-FULL                   0x0001) # Process fully & exit if error
(def PL-PARSE-QUIET                  0x0002) # Don't issue messages
(def PL-PARSE-NODELETE               0x0004) # Don't delete options after processing
(def PL-PARSE-SHOWALL                0x0008) # Show invisible options
(def PL-PARSE-OVERRIDE               0x0010) # Obsolete
(def PL-PARSE-NOPROGRAM              0x0020) # Program name NOT in *argv[0]..
(def PL-PARSE-NODASH                 0x0040) # Set if leading dash NOT required
(def PL-PARSE-SKIP                   0x0080) # Skip over unrecognized args

# FCI (font characterization integer) related constants.
(def PL-FCI-MARK                   0x80000000)
(def PL-FCI-IMPOSSIBLE             0x00000000)
(def PL-FCI-HEXDIGIT-MASK          0xf)
(def PL-FCI-HEXPOWER-MASK          0x7)
(def PL-FCI-HEXPOWER-IMPOSSIBLE    0xf)
# These define hexpower values corresponding to each font attribute.
(def PL-FCI-FAMILY                 0x0)
(def PL-FCI-STYLE                  0x1)
(def PL-FCI-WEIGHT                 0x2)
# These are legal values for font family attribute
(def PL-FCI-SANS                   0x0)
(def PL-FCI-SERIF                  0x1)
(def PL-FCI-MONO                   0x2)
(def PL-FCI-SCRIPT                 0x3)
(def PL-FCI-SYMBOL                 0x4)
# These are legal values for font style attribute
(def PL-FCI-UPRIGHT                0x0)
(def PL-FCI-ITALIC                 0x1)
(def PL-FCI-OBLIQUE                0x2)
# These are legal values for font weight attribute
(def PL-FCI-MEDIUM                 0x0)
(def PL-FCI-BOLD                   0x1)

# flags used for position argument of both pllegend and plcolorbar
(def PL-POSITION-NULL             0x0)
(def PL-POSITION-LEFT             0x1)
(def PL-POSITION-RIGHT            0x2)
(def PL-POSITION-TOP              0x4)
(def PL-POSITION-BOTTOM           0x8)
(def PL-POSITION-INSIDE           0x10)
(def PL-POSITION-OUTSIDE          0x20)
(def PL-POSITION-VIEWPORT         0x40)
(def PL-POSITION-SUBPAGE          0x80)

# Flags for pllegend.
(def PL-LEGEND-NULL               0x0)
(def PL-LEGEND-NONE               0x1)
(def PL-LEGEND-COLOR-BOX          0x2)
(def PL-LEGEND-LINE               0x4)
(def PL-LEGEND-SYMBOL             0x8)
(def PL-LEGEND-TEXT-LEFT          0x10)
(def PL-LEGEND-BACKGROUND         0x20)
(def PL-LEGEND-BOUNDING-BOX       0x40)
(def PL-LEGEND-ROW-MAJOR          0x80)

# Flags for plcolorbar
(def PL-COLORBAR-NULL             0x0)
(def PL-COLORBAR-LABEL-LEFT       0x1)
(def PL-COLORBAR-LABEL-RIGHT      0x2)
(def PL-COLORBAR-LABEL-TOP        0x4)
(def PL-COLORBAR-LABEL-BOTTOM     0x8)
(def PL-COLORBAR-IMAGE            0x10)
(def PL-COLORBAR-SHADE            0x20)
(def PL-COLORBAR-GRADIENT         0x40)
(def PL-COLORBAR-CAP-NONE         0x80)
(def PL-COLORBAR-CAP-LOW          0x100)
(def PL-COLORBAR-CAP-HIGH         0x200)
(def PL-COLORBAR-SHADE-LABEL      0x400)
(def PL-COLORBAR-ORIENT-RIGHT     0x800)
(def PL-COLORBAR-ORIENT-TOP       0x1000)
(def PL-COLORBAR-ORIENT-LEFT      0x2000)
(def PL-COLORBAR-ORIENT-BOTTOM    0x4000)
(def PL-COLORBAR-BACKGROUND       0x8000)
(def PL-COLORBAR-BOUNDING-BOX     0x10000)

# Flags for drawing mode
(def PL-DRAWMODE-UNKNOWN          0x0)
(def PL-DRAWMODE-DEFAULT          0x1)
(def PL-DRAWMODE-REPLACE          0x2)
(def PL-DRAWMODE-XOR              0x4)

#
# Define PLplot functions and signatures
#

# pl_set_contentlabelformat()

(def- c_pl_setcontlabelformat (ffi/lookup plplot-library "c_pl_setcontlabelformat"))
(def- c_pl_setcontlabelformat-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn pl-setcontlabelformat [lexp sigdig]
  (ffi/call c_pl_setcontlabelformat c_pl_setcontlabelformat-sig
            lexp sigdig))

# pl_setcontlabelparam()

(def- c_pl_setcontlabelparam (ffi/lookup plplot-library "c_pl_setcontlabelparam"))
(def- c_pl_setcontlabelparam-sig
  (ffi/signature :default
                 :void
                 :double :double :double :int32))

(defn pl-setcontlabelparam [offset size spacing active]
  (ffi/call c_pl_setcontlabelparam c_pl_setcontlabelparam-sig
            offset size spacing active))

# pladv()

(def- c_pladv (ffi/lookup plplot-library "c_pladv"))
(def- c_pladv_sig
  (ffi/signature :default
                 :void
                 :int32))

(defn pladv [page]
  (ffi/call c_pladv c_pladv_sig page))

# plarc()

(def- c_plarc (ffi/lookup plplot-library "c_plarc"))
(def- c_plarc-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double :double :double :double :int32))

(defn plarc [x y a b angle1 angle2 rotate fill]
  (ffi/call c_plarc c_plarc-sig x y a b angle1 angle2 rotate fill))

# plaxes()

(def- c_plaxes (ffi/lookup plplot-library "c_plaxes"))
(def- c_plaxes-sig
  (ffi/signature :default
                 :void
                 :double :double :string :double :int32 :string :double :int32))

(defn plaxes [x0 y0
              xopt xtick nxsub
              yopt ytick nysub]
  (let [xopt-buf (double-buf xopt)
        yopt-buf (double-buf yopt)]
    (ffi/call c_plaxes c_plaxes-sig x0 y0 xopt-buf xtick nxsub yopt-buf ytick nysub)))

# plbin()

(def- c_plbin (ffi/lookup plplot-library "c_plbin"))
(def- c_plbin-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :int32))

(defn plbin [nbin x y opt]
  (let [x-buf (double-buf x)
        y-buf (double-buf y)]
    (ffi/call c_plbin c_plbin-sig nbin x-buf y-buf opt)))

# plbtime()

(def- c_plbtime (ffi/lookup plplot-library "c_plbtime"))
(def- c_plbtime-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr :ptr :ptr :double))

(defn plbtime [ctime]
  (let [year-buf (ffi/write :int32 0)
        month-buf (ffi/write :int32 0)
        day-buf (ffi/write :int32 0)
        hour-buf (ffi/write :int32 0)
        minute-buf (ffi/write :int32 0)
        second-buf (ffi/write :double 0)]
    (ffi/call c_plbtime c_plbtime-sig
              year-buf month-buf day-buf
              hour-buf minute-buf second-buf
              ctime)
    {:year (ffi/read :int32 year-buf)
     :month (ffi/read :int32 month-buf)
     :day (ffi/read :int32 day-buf)
     :hour (ffi/read :int32 hour-buf)
     :minute (ffi/read :int32 minute-buf)
     :second (ffi/read :double second-buf)}))

# plbop()

(def- c_plbop (ffi/lookup plplot-library "c_plbop"))
(def- c_plbop-sig
  (ffi/signature :default
                 :void))

(defn plbop []
  (ffi/call c_plbop c_plbop-sig))

# plbox()

(def- c_plbox (ffi/lookup plplot-library "c_plbox"))
(def- c_plbox-sig
  (ffi/signature :default
                 :void
                 :string :double :int32 :string :double :int32))

(defn plbox [xopt xtick nxsub
             yopt ytick nysub]
  (ffi/call c_plbox c_plbox-sig xopt xtick nxsub yopt ytick nysub))

# plbox3()

(def- c_plbox3 (ffi/lookup plplot-library "c_plbox3"))
(def- c_plbox3-sig
  (ffi/signature :default
                 :void
                 :string :string :double :int32
                 :string :string :double :int32
                 :string :string :double :int32))

(defn plbox3 [xopt xlabel xtick nxsub
              yopt ylabel ytick nysub
              zopt zlabel ztick nzsub]
  (ffi/call c_plbox3 c_plbox3-sig
            xopt xlabel xtick nxsub
            yopt ylabel ytick nysub
            zopt zlabel ztick nzsub))

# plcalc_world()

(def- c_plcalc_world (ffi/lookup plplot-library "c_plcalc_world"))
(def- c_plcalc_world-sig
  (ffi/signature :default
                 :void
                 :double :double :ptr :ptr :ptr))

(defn plcalc-world [rx ry wx wy window]
  (let [wx-buf (double-buf wx)
        wy-buf (double-buf wy)]
    (ffi/call c_plcalc_world c_plcalc_world-sig
              rx ry wx-buf wy-buf window)))

# plclear()

(def- c_plclear (ffi/lookup plplot-library "c_plclear"))
(def- c_plclear-sig
  (ffi/signature :default
                 :void))

(defn plclear []
  (ffi/call c_plclear c_plclear-sig))

# plcol0()

(def- c_plcol0 (ffi/lookup plplot-library "c_plcol0"))
(def- c_plcol0-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plcol0 [icol0]
  (ffi/call c_plcol0 c_plcol0-sig icol0))

# plcol1()

(def- c_plcol1 (ffi/lookup plplot-library "c_plcol1"))
(def- c_plcol1-sig
  (ffi/signature :default
                 :void
                 :double))

(defn plcol1 [col1]
  (ffi/call c_plcol1 c_plcol1-sig col1))

# plconfigtime()

(def- c_plconfigtime (ffi/lookup plplot-library "c_plconfigtime"))
(def- c_plconfigtime-sig
  (ffi/signature :default
                 :void
                 :double :double :double :int32 :int32
                 :int32 :int32 :int32 :int32 :int32 :double))

(defn plconfigtime [scale offset1 offset2 ccontrol ifbtime_offset
                    year month day hour minute sec]
  (ffi/call c_plconfigtime c_plconfigtime-sig
            scale offset1 offset2 ccontrol ifbtime_offset
            year month day hour minute sec))

# TODO: Requires callback handling
# 
# plcont()

# (def- c_plcont (ffi/lookup plplot-library "c_plcont"))
# (def- c_plcont-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :int32 :int32 :int32 :int32
#                  :int32 :int32 :ptr :int32
#                  :ptr :ptr))

# (defn plcont [f nx ny kx lx ky ly clevel nlevel pltr pltr-data]
#   (let [f-buf (buffer/new (length f))
#         clevel-buf (buffer/new (length clevel))]
#     (each row f
#       (let [row-buf (buffer/new (length row))]
#         (each value row (buffer/push-float64 row-buf :le value))
#         (ffi/write :ptr (buffer/new (length row-buf)))))
#     (ffi/call c_plcont c_plcont-sig
#               f-buf nx ny kx lx ky ly
#               clevel-buf nlevel (callback) (fn [_] (pltr pltr-data)))))

# TODO: Required callback handling
# 
# plfcont()

# (def- plfcont (ffi/lookup plplot-library "plfcont"))
# (def- plfcont-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :int32 :int32 :int32 :int32
#                  :int32 :int32 :ptr :int32 :ptr :ptr))

# plcpstrm()

(def- c_plcpstrm (ffi/lookup plplot-library "c_plcpstrm"))
(def- c_plcpstrm-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn plcpstrm [iplsr flags]
  (ffi/call c_plcpstrm c_plcpstrm-sig iplsr flags))

# plctime()

(def- c_plctime (ffi/lookup plplot-library "c_plctime"))
(def- c_plctime-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32 :int32 :int32 :double :ptr))

(defn plctime [year month day hour minute second]
  (let [ctime-buf (ffi/write :double 0)]
    (ffi/call c_plctime c_plctime-sig year month day hour minute second ctime-buf)
    (ffi/read :double ctime-buf)))

# pldid2pc()

(def- c_pldid2pc (ffi/lookup plplot-library "pldid2pc"))
(def- c_pldid2pc-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn pldid2pc [xmin ymin xmax ymax]
  (let [xmin-buf (ffi/write :double xmin)
        ymin-buf (ffi/write :double ymin)
        xmax-buf (ffi/write :double xmax)
        ymax-buf (ffi/write :double ymax)]
    (ffi/call c_pldid2pc c_pldid2pc-sig xmin-buf ymin-buf xmax-buf ymax-buf)
    {:xmin (ffi/read :double xmin-buf)
     :ymin (ffi/read :double ymin-buf)
     :xmax (ffi/read :double xmax-buf)
     :ymax (ffi/read :double ymax-buf)}))

# pldip2dc()

(def- c_pldip2dc (ffi/lookup plplot-library "pldip2dc"))
(def- c_pldip2dc-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn pldip2dc [xmin ymin xmax ymax]
  (let [xmin-buf (ffi/write :double xmin)
        ymin-buf (ffi/write :double ymin)
        xmax-buf (ffi/write :double xmax)
        ymax-buf (ffi/write :double ymax)]
    (ffi/call c_pldip2dc c_pldip2dc-sig xmin-buf ymin-buf xmax-buf ymax-buf)
    {:xmin (ffi/read :double xmin-buf)
     :ymin (ffi/read :double ymin-buf)
     :xmax (ffi/read :double xmax-buf)
     :ymax (ffi/read :double ymax-buf)}))

# plend()

(def- c_plend (ffi/lookup plplot-library "c_plend"))
(def- c_plend-sig
  (ffi/signature :default
                 :void))

(defn plend []
  (ffi/call c_plend c_plend-sig))

# plend1()

(def- c_plend1 (ffi/lookup plplot-library "c_plend1"))
(def- c_plend1-sig
  (ffi/signature :default
                 :void))

(defn plend1 []
  (ffi/call c_plend1 c_plend1-sig))

# plenv()

(def- c_plenv (ffi/lookup plplot-library "c_plenv"))
(def- c_plenv-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double :int32 :int32))

(defn plenv [xmin xmax ymin ymax just axis]
  (ffi/call c_plenv c_plenv-sig xmin xmax ymin ymax just axis))

# plenv0()

(def- c_plenv0 (ffi/lookup plplot-library "c_plenv0"))
(def- c_plenv0-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double :int32 :int32))

(defn plenv0 [xmin xmax ymin ymax just axis]
  (ffi/call c_plenv0 c_plenv0-sig xmin xmax ymin ymax just axis))

# pleop()

(def- c_pleop (ffi/lookup plplot-library "c_pleop"))
(def- c_pleop-sig
  (ffi/signature :default
                 :void))

(defn pleop []
  (ffi/call c_pleop c_pleop-sig))

# plerrx()

(def- c_plerrx (ffi/lookup plplot-library "c_plerrx"))
(def- c_plerrx-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr))

(defn plerrx [xmin xmax y]
  (assert (= (length xmin) (length xmax) (length y)))
  (let [n (length xmin)
        xmin-buf (double-buf xmin)
        xmax-buf (double-buf xmax)
        y-buf (double-buf y)]
    (ffi/call c_plerrx c_plerrx-sig n xmin-buf xmax-buf y-buf)))

# plerry()

(def- c_plerry (ffi/lookup plplot-library "c_plerry"))
(def- c_plerry-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr))

(defn plerry [x ymin ymax]
  (assert (= (length x) (length ymin) (length ymax)))
  (let [n (length x)
        x-buf (double-buf x)
        ymin-buf (double-buf ymin)
        ymax-buf (double-buf ymax)]
    (ffi/call c_plerry c_plerry-sig x-buf ymin-buf ymax-buf)))

# plfamadv()

(def- c_plfamadv (ffi/lookup plplot-library "c_plfamadv"))
(def- c_plfamadv-sig
  (ffi/signature :default
                 :void))

(defn plfamadv []
  (ffi/call c_plfamadv c_plfamadv-sig))

# plfill()

(def- c_plfill (ffi/lookup plplot-library "c_plfill"))
(def- c_plfill-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr))

(defn plfill [x y]
  (assert (= (length x) (length y)))
  (let [n (length x)
        x-buf (double-buf x)
        y-buf (double-buf y)]
    (ffi/call c_plfill c_plfill-sig n x-buf y-buf)))

# plfill3()

(def- c_plfill3 (ffi/lookup plplot-library "c_plfill3"))
(def- c_plfill3-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr))

(defn plfill3 [x y z]
  (assert (= (length x) (length y) (length z)))
  (let [n (length x)
        x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-buf z)]
    (ffi/call c_plfill3 c_plfill3-sig n x-buf y-buf z-buf)))

# plflush()

(def- c_plflush (ffi/lookup plplot-library "c_plflush"))
(def- c_plflush-sig
  (ffi/signature :default
                 :void))

(defn plflush []
  (ffi/call c_plflush c_plflush-sig))

# plfont()

(def- c_plfont (ffi/lookup plplot-library "c_plfont"))
(def- c_plfont-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plfont [ifont]
  (ffi/call c_plfont c_plfont-sig ifont))

# plfontld

(def- c_plfontld (ffi/lookup plplot-library "c_plfontld"))
(def- c_plfontld-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plfontld [fnt]
  (ffi/call c_plfontld c_plfontld-sig fnt))

# plgchr()

(def- c_plgchr (ffi/lookup plplot-library "c_plgchr"))
(def- c_plgchr-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr))

(defn plgchr []
  (let [def-buf (ffi/write :double 0)
        ht-buf (ffi/write :double 0)]
    (ffi/call c_plgchr c_plgchr-sig def-buf ht-buf)
    {:def (ffi/read :double def-buf)
     :ht (ffi/read :double ht-buf)}))

# plgcmap1_range()

(def- c_plgcmap1_range (ffi/lookup plplot-library "c_plgcmap1_range"))
(def- c_plgcmap1_range-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr))

(defn plgcmap1-range []
  (let [min-color-buf (ffi/write :double 0)
        max-color-buf (ffi/write :double 0)]
    (ffi/call c_plgcmap1_range c_plgcmap1_range-sig min-color-buf max-color-buf)
    {:min-color (ffi/read :double min-color-buf)
     :max-color (ffi/read :double max-color-buf)}))

# plgcol0()

(def- c_plgcol0 (ffi/lookup plplot-library "c_plgcol0"))
(def- c_plgcol0-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr))

(defn plgcol0 [icol0]
  (let [r-buf (ffi/write :int32 0)
        g-buf (ffi/write :int32 0)
        b-buf (ffi/write :int32 0)]
    (ffi/call c_plgcol0 c_plgcol0-sig icol0 r-buf g-buf b-buf)
    {:r (ffi/read :int32 r-buf)
     :g (ffi/read :int32 g-buf)
     :b (ffi/read :int32 b-buf)}))

# plgcol0a

(def- c_plgcol0a (ffi/lookup plplot-library "c_plgcol0a"))
(def- c_plgcol0a-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr :ptr))

(defn plgcol0a [icol0]
  (let [r-buf (ffi/write :double 0)
        g-buf (ffi/write :double 0)
        b-buf (ffi/write :double 0)
        alpha-buf (ffi/write :double 0)]
    (ffi/call c_plgcol0a c_plgcol0a c_plgcol0a-sig icol0 r-buf g-buf b-buf)
    {:r (ffi/read :double r-buf)
     :g (ffi/read :double g-buf)
     :b (ffi/read :double b-buf)
     :alpha (ffi/read :double alpha-buf)}))

# plgcolbg()

(def- c_plgcolbg (ffi/lookup plplot-library "c_plgcolbg"))
(def- c_plgcolbg-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr))

(defn plgcolbg []
  (let [r-buf (ffi/write :double 0)
        g-buf (ffi/write :double 0)
        b-buf (ffi/write :double 0)]
    (ffi/call c_plgcolbg c_plgcolbg-sig r-buf g-buf b-buf)
    {:r (ffi/read :double r-buf)
     :g (ffi/read :double g-buf)
     :b (ffi/read :double b-buf)}))

# plgcolbga()

(def- c_plgcolbga (ffi/lookup plplot-library "c_plgcolbga"))
(def- c_plgcolbga-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn plgcolbga []
  (let [r-buf (ffi/write :double 0)
        g-buf (ffi/write :double 0)
        b-buf (ffi/write :double 0)
        alpha-buf (ffi/write :double 0)]
    (ffi/call c_plgcolbga c_plgcolbga-sig r-buf g-buf b-buf alpha-buf)
    {:r (ffi/read :double r-buf)
     :g (ffi/read :double g-buf)
     :b (ffi/read :double b-buf)
     :alpha (ffi/read :double alpha-buf)}))

# plgcompression()

(def- c_plgcompression (ffi/lookup plplot-library "c_plgcompression"))
(def- c_plgcompression-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plgcompression []
  (let [compression-buf (ffi/write :int32 0)]
    (ffi/call c_plgcompression c_plgcompression-sig compression-buf)
    (ffi/read :int32 compression-buf)))

# plgdev()

(def- c_plgdev (ffi/lookup plplot-library "c_plgdev"))
(def- c_plgdev-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plgdev []
  (let [dev (buffer/new-filled 80)
        dev-ptr (ffi/write :ptr dev)]
    (ffi/call c_plgdev c_plgdev-sig dev)
    (string/slice dev 0 (index-of 0 dev))))

# plgdidev()

(def- c_plgdidev (ffi/lookup plplot-library "c_plgdidev"))
(def- c_plgdidev-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn plgdidev []
  (let [max-buf (ffi/write :double 0)
        aspect-buf (ffi/write :double 0)
        jx-buf (ffi/write :double 0)
        jy-buf (ffi/write :double 0)]
    (ffi/call c_plgdidev c_plgdidev-sig max-buf aspect-buf jx-buf jy-buf)
    {:max (ffi/read :double max-buf)
     :aspect (ffi/read :double aspect-buf)
     :jx (ffi/read :double jx-buf)
     :jy (ffi/read :double jy-buf)}))

# plgdiori()

(def- c_plgdiori (ffi/lookup plplot-library "c_plgdiori"))
(def- c_plgdiori-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plgdiori []
  (let [rot-buf (ffi/write :double 0)]
    (ffi/call c_plgdiori c_plgdiori-sig rot-buf)
    (ffi/read :double rot-buf)))

# plgdiplt()

(def- c_plgdiplt (ffi/lookup plplot-library "c_plgdiplt"))
(def- c_plgdiplt-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn plgdiplt []
  (let [xmin-buf (ffi/write :double 0)
        ymin-buf (ffi/write :double 0)
        xmax-buf (ffi/write :double 0)
        ymax-buf (ffi/write :double 0)]
    (ffi/call c_plgdiplt c_plgdiplt-sig xmin-buf ymin-buf xmax-buf ymax-buf)
    {:xmin (ffi/read :double xmin-buf)
     :ymin (ffi/read :double ymin-buf)
     :xmax (ffi/read :double xmax-buf)
     :ymax (ffi/read :double ymax-buf)}))

# plgdrawmode()

(def- c_plgdrawmode (ffi/lookup plplot-library "c_plgdrawmode"))
(def- c_plgdrawmode-sig
  (ffi/signature :default
                 :int32))

(defn plgdrawmode []
  (ffi/call c_plgdrawmode c_plgdrawmode-sig))

# plgfci

(def- c_plgfci (ffi/lookup plplot-library "c_plgfci"))
(def- c_plgfci-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plgfci []
  (let [fci-buf (ffi/write :uint32 0)]
    (ffi/call c_plgfci c_plgfci-sig fci-buf)
    (ffi/read :uint32 fci-buf)))

# plgfam()

(def- c_plgfam (ffi/lookup plplot-library "c_plgfam"))
(def- c_plgfam-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr))

(defn plgfam []
  (let [fam-buf (ffi/write :int32 0)
        num-buf (ffi/write :int32 0)
        bmax-buf (ffi/write :int32 0)]
    (ffi/call c_plgfam c_plgfam-sig fam-buf num-buf bmax-buf)
    {:fam (ffi/read :int32 fam-buf)
     :num (ffi/read :int32 num-buf)
     :bmax (ffi/read :int32 bmax-buf)}))

# plgfnam()

(def- c_plgfnam (ffi/lookup plplot-library "c_plgfnam"))
(def- c_plgfnam-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plgfnam []
  (let [fnam (buffer/new-filled 80)
        fnam-ptr (ffi/write :ptr fnam)]
    (ffi/call c_plgfnam c_plgfnam-sig fnam-ptr)
    (string/slice fnam 0 (index-of 0 fnam))))

# plgfont()

(def- c_plgfont (ffi/lookup plplot-library "c_plgfont"))
(def- c_plgfont-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr))

(defn plgfont []
  (let [family-buf (ffi/write :int32 0)
        style-buf (ffi/write :int32 0)
        weight-buf (ffi/write :int32 0)]
    (ffi/call c_plgfont c_plgfont-sig family-buf style-buf weight-buf)
    {:family (ffi/read :int32 family-buf)
     :style (ffi/read :int32 style-buf)
     :weight (ffi/read :int32 weight-buf)}))

# plglevel()

(def- c_plglevel (ffi/lookup plplot-library "c_plglevel"))
(def- c_plglevel-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plglevel []
  (let [level-buf (ffi/write :int32 0)]
    (ffi/call c_plglevel c_plglevel-sig level-buf)
    (ffi/read :int32 level-buf)))

# plgpage()

(def- c_plgpage (ffi/lookup plplot-library "c_plgpage"))
(def- c_plgpage-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr :ptr :ptr))

(defn plgpage []
  (let [xp-buf (ffi/write :double 0)
        yp-buf (ffi/write :double 0)
        xleng-buf (ffi/write :int32 0)
        yleng-buf (ffi/write :int32)
        xoff-buf (ffi/write :int32)
        yoff-buf (ffi/write :int32)]
    (ffi/call c_plgpage c_plgpage-sig
              xp-buf yp-buf xleng-buf yleng-buf xoff-buf yoff-buf)
    {:xp (ffi/read :double xp-buf)
     :yp (ffi/read :double yp-buf)
     :xleng (ffi/read :int32 xleng-buf)
     :yleng (ffi/read :int32 yleng-buf)
     :xoff (ffi/read :int32 xoff-buf)
     :yoff (ffi/read :int32 yoff-buf)}))

# plgra()

(def- c_plgra (ffi/lookup plplot-library "c_plgra"))
(def- c_plgra-sig
  (ffi/signature :default
                 :void))

(defn plgra []
  (ffi/call c_plgra c_plgra-sig))

# plgradient()

(def- c_plgradient (ffi/lookup plplot-library "c_plgradient"))
(def- c_plgradient-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :double))

(defn plgradient [x y angle]
  (assert (= (length x) (length y)))
  (let [n (length x)
        x-buf (double-buf x)
        y-buf (double-buf y)]
    (ffi/call c_plgradient c_plgradient-sig n x-buf y-buf angle)))

# plgriddata()

(def- c_plgriddata (ffi/lookup plplot-library "c_plgriddata"))
(def- c_plgriddata-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32
                 :ptr :int32 :ptr :int32
                 :ptr :int32 :double))

(defn plgriddata [x y z xg yg zg grid-type data]
  (assert (= (length x) (length y) (length z)))
  (let [n (length x)
        x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-buf z)
        xg-buf (double-buf xg)
        yg-buf (double-buf yg)
        zg-buf (double-buf zg)]
    (ffi/call c_plgriddata c_plgriddata-sig
              x-buf y-buf z-buf n
              xg-buf (length xg)
              yg-buf (length yg)
              zg-buf (length zg)
              grid-type
              data)))

# TODO: Requires array of callback functions similar to
# 
# static plf2ops_t s_plf2ops_c = {
#     plf2ops_c_get,
#     plf2ops_c_set,
#     plf2ops_c_add,
#     plf2ops_c_sub,
#     plf2ops_c_mul,
#     plf2ops_c_div,
#     plf2ops_c_isnan,
#     plf2ops_c_minmax,
#     plf2ops_c_f2eval
# };
# 
# plgriddata() uses this behind the scenes when calling plfgriddata
# behind the scenes
# 
# plfgriddata()

# (def- plfgriddata (ffi/lookup plplot-library "plfgriddata"))
# (def- plfgriddata-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :int32
#                  :ptr :int32 :ptr :int32
#                  :ptr :ptr :int32 :double))

# plgspa()

(def- c_plgspa (ffi/lookup plplot-library "c_plgspa"))
(def- c_plgspa-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn plgspa []
  (let [xmin-buf (ffi/write :double 0)
        xmax-buf (ffi/write :double 0)
        ymin-buf (ffi/write :double 0)
        ymax-buf (ffi/write :double 0)]
    (ffi/call c_plgspa c_plgspa-sig xmin-buf xmax-buf ymin-buf ymax-buf)
    {:xmin (ffi/read :double xmin-buf)
     :xmax (ffi/read :double xmax-buf)
     :ymin (ffi/read :double ymin-buf)
     :ymax (ffi/read :double ymax-buf)}))

# plgstrm()

(def- c_plgstrm (ffi/lookup plplot-library "c_plgstrm"))
(def- c_plgstrm-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plgstrm []
  (let [strm-buf (ffi/write :int32 0)]
    (ffi/call c_plgstrm c_plgstrm-sig strm-buf)
    (ffi/read :int32 strm-buf)))

# plgver

(def- c_plgver (ffi/lookup plplot-library "c_plgver"))
(def- c_plgver-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plgver []
  (let [ver-buf (buffer/new-filled 80)]
    (ffi/call c_plgver c_plgver-sig ver-buf)
    (string/slice ver-buf 0 (index-of 0 ver-buf))))

# plgvpd()

(def- c_plgvpd (ffi/lookup plplot-library "c_plgvpd"))
(def- c_plgvpd-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn plgvpd []
  (let [xmin-buf (ffi/write :double 0)
        xmax-buf (ffi/write :double 0)
        ymin-buf (ffi/write :double 0)
        ymax-buf (ffi/write :double 0)]
    (ffi/call c_plgvpd c_plgvpd-sig xmin-buf xmax-buf ymin-buf ymax-buf)
    {:xmin (ffi/read :double xmin-buf)
     :xmax (ffi/read :double xmax-buf)
     :ymin (ffi/read :double ymin-buf)
     :ymax (ffi/read :double ymax-buf)}))

# plgvpw()

(def- c_plgvpw (ffi/lookup plplot-library "c_plgvpw"))
(def- c_plgvpw-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr))

(defn plgvpw []
  (let [xmin-buf (ffi/write :double 0)
        xmax-buf (ffi/write :double 0)
        ymin-buf (ffi/write :double 0)
        ymax-buf (ffi/write :double 0)]
    (ffi/call c_plgvpw c_plgvpd-sig xmin-buf xmax-buf ymin-buf ymax-buf)
    {:xmin (ffi/read :double xmin-buf)
     :xmax (ffi/read :double xmax-buf)
     :ymin (ffi/read :double ymin-buf)
     :ymax (ffi/read :double ymax-buf)}))

# plgxax()

(def- c_plgxax (ffi/lookup plplot-library "c_plgxax"))
(def- c_plgxax-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr))

(defn plgxax []
  (let [digmax-buf (ffi/write :int32 0)
        digits-buf (ffi/write :int32 0)]
    (ffi/call c_plgxax c_plgxax-sig digmax-buf digits-buf)
    {:digmax (ffi/read :int32 digmax-buf)
     :digits (ffi/read :int32 digits-buf)}))

# plgyax()

(def- c_plgyax (ffi/lookup plplot-library "c_plgyax"))
(def- c_plgyax-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr))

(defn plgyax []
  (let [digmax-buf (ffi/write :int32 0)
        digits-buf (ffi/write :int32 0)]
    (ffi/call c_plgyax c_plgxax-sig digmax-buf digits-buf)
    {:digmax (ffi/read :int32 digmax-buf)
     :digits (ffi/read :int32 digits-buf)}))

# plgzax()

(def- c_plgzax (ffi/lookup plplot-library "c_plgzax"))
(def- c_plgzax-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr))

(defn plgzax []
  (let [digmax-buf (ffi/write :int32 0)
        digits-buf (ffi/write :int32 0)]
    (ffi/call c_plgzax c_plgxax-sig digmax-buf digits-buf)
    {:digmax (ffi/read :int32 digmax-buf)
     :digits (ffi/read :int32 digits-buf)}))

# plhist()

(def- c_plhist (ffi/lookup plplot-library "c_plhist"))
(def- c_plhist-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :double :double :int32 :int32))

(defn plhist [data datmin datmax nbin opt]
  (let [n (length data)
        data-buf (double-buf data)]
    (ffi/call c_plhist c_plhist-sig n data-buf datmin datmax nbin opt)))

# plhlsrgb()

(def- c_plhlsrgb (ffi/lookup plplot-library "c_plhlsrgb"))
(def- c_plhlsrgb-sig
  (ffi/signature :default
                 :void
                 :double :double :double :ptr :ptr :ptr))

(defn plhlsrgb [h l s]
  (let [r-buf (ffi/write :double 0)
        g-buf (ffi/write :double 0)
        b-buf (ffi/write :double 0)]
    (ffi/call c_plhlsrgb c_plhlsrgb-sig h l s r-buf g-buf b-buf)
    {:r (ffi/read :double r-buf)
     :g (ffi/read :double g-buf)
     :b (ffi/read :double b-buf)}))

# plinit()

(def- c_plinit (ffi/lookup plplot-library "c_plinit"))
(def- c_plinit-sig
  (ffi/signature :default
                 :void))

(defn plinit []
  (ffi/call c_plinit c_plinit-sig))

# pljoin()

(def- c_pljoin (ffi/lookup plplot-library "c_pljoin"))
(def- c_pljoin-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double))

(defn pljoin [x1 y1 x2 y2]
  (ffi/call c_pljoin c_pljoin-sig x1 y1 x2 y2))

# pllab()

(def- c_pllab (ffi/lookup plplot-library "c_pllab"))
(def- c_pllab-sig
  (ffi/signature :default
                 :void
                 :string :string :string))

(defn pllab [xlabel ylabel tlabel]
  (ffi/call c_pllab c_pllab-sig xlabel ylabel tlabel))

# pllegend()

(def- c_pllegend (ffi/lookup plplot-library "c_pllegend"))
(def- c_pllegend-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :int32 :int32 :double :double :double
                 :int32 :int32 :int32 :int32 :int32
                 :int32 :ptr :double :double :double
                 :double :ptr :ptr :ptr :ptr :ptr :ptr
                 :ptr :ptr :ptr :ptr :ptr :ptr :ptr))

(defn pllegend [opt position x y plot-width
                bg-color bb-color bb-style
                nrow ncolumn opt-array
                text-offset text-scale text-spacing text-justification
                text-colors text
                box-colors box-patterns box-scales box-line-widths
                line-colors line-styles line-widths
                symbol-colors symbol-scales symbol-numbers symbols] 
  (let [legend-width-buf (ffi/write :double 0)
        legend-height-buf (ffi/write :double 0)
        opt-array-buf (int32-buf opt-array)
        text-colors-buf (int32-buf text-colors)
        text-buf (strings-buf text)
        box-colors-buf (int32-buf box-colors)
        box-patterns-buf (int32-buf box-patterns)
        box-scales-buf (double-buf box-scales)
        box-line-widths-buf (double-buf box-line-widths)
        line-colors-buf (int32-buf line-colors)
        line-styles-buf (int32-buf line-styles)
        line-widths-buf (double-buf line-widths)
        symbol-colors-buf (int32-buf symbol-colors)
        symbol-scales-buf (int32-buf symbol-scales)
        symbol-numbers-buf (int32-buf symbol-numbers)
        symbols-buf (strings-buf symbols)]
    (ffi/call c_pllegend c_pllegend-sig
              legend-width-buf legend-height-buf
              opt position x y plot-width
              bg-color bb-color bb-style
              nrow ncolumn (length text)
              opt-array-buf
              text-offset text-scale text-spacing text-justification
              text-colors-buf text-buf
              box-colors-buf box-patterns-buf
              box-scales-buf box-line-widths-buf
              line-colors-buf line-styles-buf line-widths-buf
              symbol-colors-buf symbol-scales-buf
              symbol-numbers-buf symbols-buf)
    {:legend-width (ffi/read :double legend-width-buf)
     :legend-height (ffi/read :double legend-height-buf)}))

# plcolorbar()

(def- c_plcolorbar (ffi/lookup plplot-library "c_plcolorbar"))
(def- c_plcolorbar-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :int32 :int32 :double :double
                 :double :double :int32 :int32 :int32
                 :double :double :int32 :double :int32
                 :ptr :ptr :int32 :ptr :ptr :ptr :ptr :ptr))

(defn plcolorbar [opt position x y x-length y-length
                  bg-color bb-color bb-style
                  low-cap-color high-cap-color
                  cont-color cont-width
                  label-opts labels
                  axis-opts ticks sub-ticks plot-values]
  (let [colorbar-width-buf (ffi/write :double 0)
        colorbar-height-buf (ffi/write :double 0)
        n-labels (length labels)
        label-opts-buf (int32-buf label-opts)
        labels-buf (strings-buf labels)
        n-axis (length axis-opts)
        axis-opts-buf (strings-buf axis-opts)
        ticks-buf (double-buf ticks)
        sub-ticks-buf (int32-buf sub-ticks)
        n-values (length values)
        values-buf (double-matrix-buf plot-values)]
    (ffi/call c_plcolorbar c_plcolorbar-sig
              colorbar-width-buf colorbar-height-buf
              opt position x y x-length y-length
              bg-color bb-color bb-style
              low-cap-color high-cap-color
              cont-color cont-width
              n-labels label-opts-buf labels-buf
              n-axis axis-opts-buf
              ticks-buf sub-ticks-buf
              n-values values-buf)))

# pllightsource()

(def- c_pllightsource (ffi/lookup plplot-library "c_pllightsource"))
(def- c_pllightsource-sig
  (ffi/signature :default
                 :void
                 :double :double :double))

(defn pllightsource [x y z]
  (ffi/call c_pllightsource c_pllightsource-sig x y z))

# plline()

(def- c_plline (ffi/lookup plplot-library "c_plline"))
(def- c_plline-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr))

(defn plline [x y]
  (assert (= (length x) (length y)))
  (let [n (length x)
        x-buf (double-buf x)
        y-buf (double-buf y)]
    (ffi/call c_plline c_plline-sig n x-buf y-buf)))

# plline3()

(def- c_plline3 (ffi/lookup plplot-library "c_plline3"))
(def- c_plline3-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr))

(defn plline3 [x y z]
  (assert (= (length x) (length y) (length z)))
  (let [n (length x)
        x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-buf z)]
    (ffi/call c_plline3 c_plline3-sig n x-buf y-buf z-buf)))

# pllsty()

(def- c_pllsty (ffi/lookup plplot-library "c_pllsty"))
(def- c_pllsty-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn pllsty [lin]
  (ffi/call c_pllsty c_pllsty-sig lin))

# TODO: Requires callback
# plmap()

# (def- c_plmap (ffi/lookup plplot-library "c_plmap"))
# (def- c_plmap-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :double :double :double :double))

# TODO: Requires callback
# 
# plmapline()

# (def- c_plmapline (ffi/lookup plplot-library "c_plmapline"))
# (def- c_plmapline-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :double :double :double :double
#                  :ptr :int32))

# TODO: Requires callback
# 
# plmapstring()

# (def- c_plmapstring (ffi/lookup plplot-library "c_plmapstring"))
# (def- c_plmapstring-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :double :double :double :double
#                  :ptr :ptr))

# TODO: Requires callback
# 
# plmaptex()

# (def- c_plmaptex (ffi/lookup plplot-library "c_plmaptex"))
# (def- c_plmaptex-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :double :double :double :ptr
#                  :double :double :double :double :int32))

# TODO: Requires callback
# 
# plmapfill()

# (def- c_plmapfill (ffi/lookup plplot-library "c_plmapfill"))
# (def- c_plmapfill-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :double :double :double :double
#                  :ptr :int32))

# TODO: Requires callback
# 
# plmeridians()

# (def- c_plmeridians (ffi/lookup plplot-library "c_plmeridians"))
# (def- c_plmeridians-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :double :double :double :double :double :double))

# plmesh()

(def- c_plmesh (ffi/lookup plplot-library "c_plmesh"))
(def- c_plmesh-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32 :int32 :int32))

(defn plmesh [x y z opt]
  (assert (= (length y) (length z)))
  (assert (every? (map (fn [row] (= (length x) (length row))) z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-matrix-buf z)]
    (ffi/call c_plmesh c_plmesh-sig x-buf y-buf z-buf (length x) (length y) opt)))

# TODO: Requires callback
# 
# plfmesh()

# (def- plfmesh (ffi/lookup plplot-library "plfmesh"))
# (def- plfmesh-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :int32))

# plmeshc()

(def- c_plmeshc (ffi/lookup plplot-library "c_plmeshc"))
(def- c_plmeshc-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32 :int32 :int32 :ptr :int32))

(defn plmeshc [x y z opt clevel]
  (assert (= (length y) (length z)))
  (assert (every? (map (fn [row] (= (length x) (length row))) z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-matrix-buf z)
        clevel-buf (double-buf clevel)]
    (ffi/call c_plmeshc c_plmeshc-sig x-buf y-buf z-buf (length x) (length y) opt clevel-buf (length clevel))))

# TODO: Requires callback
# 
# plfmeshc()

# (def- plfmeshc (ffi/lookup plplot-library "plfmeshc"))
# (def- plfmeshc-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :int32 :ptr :int32))

# plmkstrm()

(def- c_plmkstrm (ffi/lookup plplot-library "c_plmkstrm"))
(def- c_plmkstrm-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plmkstrm []
  (let [strm-buf (ffi/write :int32 0)]
    (ffi/call c_plmkstrm c_plmkstrm-sig strm-buf)
    (ffi/read :int32 strm-buf)))

# plmtex()

(def- c_plmtex (ffi/lookup plplot-library "c_plmtex"))
(def- c_plmtex-sig
  (ffi/signature :default
                 :void
                 :string :double :double :double :string))

(defn plmtex [side disp pos just text]
  (ffi/call c_plmtex c_plmtex-sig side disp pos just text))

# plmtex3

(def- c_plmtex3 (ffi/lookup plplot-library "c_plmtex3"))
(def- c_plmtex3-sig
  (ffi/signature :default
                 :void
                 :string :double :double :double :string))

(defn plmtex3 [side disp pos just text]
  (ffi/call c_plmtex3 c_plmtex3-sig side disp pos just text))

# plot3d()

(def- c_plot3d (ffi/lookup plplot-library "c_plot3d"))
(def- c_plot3d-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32 :int32 :int32 :int32))

(defn plot3d [x y z opt side]
  (assert (length y) (length z))
  (assert (every? (map (fn [row] (= (length x) (length row))) z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-matrix-buf z)]
    (ffi/call c_plot3d c_plot3d-sig x-buf y-buf z-buf (length x) (length y) opt side)))

# TODO: Requires callback
# 
# plfplot3d()

# (def- plfplot3d (ffi/lookup plplot-library "plfplot3d"))
# (def- plfplot3d-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :int32 :int32))

# plot3dc()

(def- c_plot3dc (ffi/lookup plplot-library "c_plot3dc"))
(def- c_plot3dc-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32 :int32 :int32 :ptr :int32))

(defn plot3dc [x y z opt clevel]
  (assert (length y) (length z))
  (assert (every? (map (fn [row] (= (length x) (length row))) z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-matrix-buf z)
        clevel-buf (double-buf clevel)]
    (ffi/call c_plot3dc c_plot3dc-sig
              x-buf y-buf z-buf (length x) (length y) opt clevel-buf (length clevel))))

# TODO: Requires callback
# 
# plfplot3dc()

# (def- plfplot3dc (ffi/lookup plplot-library "plfplot3dc"))
# (def- plfplot3dc-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :int32 :ptr :int32))

(def- c_plot3dcl (ffi/lookup plplot-library "c_plot3dcl"))
(def- c_plot3dcl-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32 :int32 :int32 :ptr :int32
                 :int32 :int32 :ptr :ptr))

(defn plot3dcl [x y z opt clevel index-xmin index-xmax index-ymin index-ymax]
  (assert (= (length y) (length z)))
  (assert (every? (map (fn [row] (= (length x) (length row))) z)))
  (assert (=))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-matrix-buf z)
        clevel-buf (double-buf clevel)
        index-ymin-buf (int32-buf index-ymin)
        index-ymax-buf (int32-buf index-ymax)]
    (ffi/call c_plot3dcl c_plot3dcl-sig
              x-buf y-buf z-buf (length x) (length y)
              opt clevel-buf (length clevel)
              index-xmin index-xmax index-ymin-buf index-ymin-buf)))

# TODO: Requires callback
# 
# plfplot3dcl()

# (def- plfplot3dcl (ffi/lookup plplot-library "plfplot3dcl"))
# (def- plfplot3dcl-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :int32
#                  :ptr :int32 :int32 :int32 :ptr :ptr))

# plpat()

(def- c_plpat (ffi/lookup plplot-library "c_plpat"))
(def- c_plpat-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr))

(defn plpat [inclination spacing]
  (assert (= (length inclination) (length spacing)))
  (let [inclination-buf (int32-buf inclination)
        spacing-buf (int32-buf spacing)]
    (ffi/call (length inclination) inclination-buf spacing-buf)))

# plpath()

(def- c_plpath (ffi/lookup plplot-library "c_plpath"))
(def- c_plpath-sig
  (ffi/signature :default
                 :void
                 :int32 :double :double :double :double))

(defn plpath [n x1 y1 x2 y2]
  (ffi/call c_plpath c_plpath-sig n x1 y1 x2 y2))

# plpoin()

(def- c_plpoin (ffi/lookup plplot-library "c_plpoin"))
(def- c_plpoin-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :int32))

(defn plpoin [x y code]
  (assert (= (length x) (length y)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)]
    (ffi/call c_plpoin c_plpoin-sig (length x) x-buf y-buf code)))

# plpoin3()

(def- c_plpoin3 (ffi/lookup plplot-library "c_plpoin3"))
(def- c_plpoin3-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr :int32))

(defn plpoin3 [x y z code]
  (assert (= (length x) (length y) (length z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-buf z)]
    (ffi/call c_plpoin3 c_plpoin3-sig (length x) x-buf y-buf z-buf code)))

# plploly3()

(def- c_plpoly3 (ffi/lookup plplot-library "c_plpoly3"))
(def- c_plpoly3-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr :ptr :int32))

(defn plploly3 [x y z draw ifcc]
  (assert (= (length x) (length y) (length z) (inc (length draw))))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-buf z)
        draw-buf (int32-buf draw)]
    (ffi/call c_plpoly3 c_plpoly3-sig
              (length x) x-buf y-buf z-buf draw-buf ifcc)))

# plprec()

(def- c_plprec (ffi/lookup plplot-library "c_plprec"))
(def- c_plprec-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn plprec [setp prec]
  (ffi/call c_plprec c_plprec-sig setp prec))

# plpsty()

(def- c_plpsty (ffi/lookup plplot-library "c_plpsty"))
(def- c_plpsty-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plpsty [patt]
  (ffi/call c_plpsty c_plpsty-sig patt))

# plptex()

(def- c_plptex (ffi/lookup plplot-library "c_plptex"))
(def- c_plptex-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double :double :string))

(defn plptex [x y dx dy just text]
  (ffi/call c_plptex c_plptex-sig x y dx dy just text))

# plptex3

(def- c_plptex3 (ffi/lookup plplot-library "c_plptex3"))
(def- c_plptex3-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double :double :double
                 :double :double :double :double :string))

(defn plptex3 [wx wy wz dx dy dz sx sy sz just text]
  (ffi/call c_plptex3 c_plptex3-sig
            wx wy wz dx dy dz sx sy sz just text))

# plrandd()

(def- c_plrandd (ffi/lookup plplot-library "c_plrandd"))
(def- c_plrandd-sig
  (ffi/signature :default
                 :void))

(defn plrandd []
  (ffi/call c_plrandd c_plrandd-sig))

# plreplot()

(def- c_plreplot (ffi/lookup plplot-library "c_plreplot"))
(def- c_plreplot-sig
  (ffi/signature :default
                 :void))

(defn plreplot []
  (ffi/call c_plreplot c_plreplot-sig))

# plrgbhls()

(def- c_plrgbhls (ffi/lookup plplot-library "c_plrgbhls"))
(def- c_plrgbhls-sig
  (ffi/signature :default
                 :void
                 :double :double :double :ptr :ptr :ptr))

(defn plrgbhls [r g b]
  (let [h-buf (ffi/write :double 0)
        l-buf (ffi/write :double 0)
        s-buf (ffi/write :double 0)]
    (ffi/call c_plrgbhls c_plrgbhls-sig r g b h-buf l-buf s-buf)
    {:h (ffi/read :double h-buf)
     :l (ffi/read :double l-buf)
     :s (ffi/read :double s-buf)}))

# plschr()

(def- c_plschr (ffi/lookup plplot-library "c_plschr"))
(def- c_plschr-sig
  (ffi/signature :default
                 :void
                 :double :double))

(defn plschr [default-height scale]
  (ffi/call c_plschr c_plschr-sig default-height scale))

# plscmap0()

(def- c_plscmap0 (ffi/lookup plplot-library "c_plscmap0"))
(def- c_plscmap0-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32))

(defn plscmap0 [r g b]
  (assert (= (length r) (length g) (length b)))
  (let [r-buf (int32-buf r)
        g-buf (int32-buf g)
        b-buf (int32-buf b)]
    (ffi/call c_plscmap0 c_plscmap0-sig r-buf g-buf b-buf (length r))))

# plscmap0a()

(def- c_plscmap0a (ffi/lookup plplot-library "c_plscmap0a"))
(def- c_plscmap0a-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr :int32))

(defn plscmap0a [r g b alpha]
  (assert (= (length r) (length g) (length b) (length alpha)))
  (let [r-buf (int32-buf r)
        g-buf (int32-buf g)
        b-buf (int32-buf b)
        alpha-buf (double-buf alpha)]
    (ffi/call c_plscmap0a c_plscmap0a-sig r-buf g-buf b-buf alpha-buf)))

# plscmap0n

(def- c_plscmap0n (ffi/lookup plplot-library "c_plscmap0n"))
(def- c_plscmap0n-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plscmap0n [ncol0]
  (ffi/call c_plscmap0n c_plscmap0n-sig ncol0))

# plscmap1()

(def- c_plscmap1 (ffi/lookup plplot-library "c_plscmap1"))
(def- c_plscmap1-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32))

(defn plscmap1 [r g b]
  (assert (= (length r) (length g) (length b)))
  (let [r-buf (int32-buf r)
        g-buf (int32-buf g)
        b-buf (int32-buf b)]
    (ffi/call c_plscmap1 c_plscmap1-sig r-buf g-buf b-buf (length r))))

# plscmap1a()

(def- c_plscmap1a (ffi/lookup plplot-library "c_plscmap1a"))
(def- c_plscmap1a-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :ptr :int32))

(defn plscmap1a [r g b alpha]
  (assert (= (length r) (length g) (length b) (length alpha)))
  (let [r-buf (int32-buf r)
        g-buf (int32-buf g)
        b-buf (int32-buf b)
        alpha-buf (double-buf alpha)]
    (ffi/call c_plscmap1a c_plscmap1a-sig r-buf g-buf b-buf alpha-buf (length r))))

# plscmap1l()

(def- c_plscmap1l (ffi/lookup plplot-library "c_plscmap1l"))
(def- c_plscmap1l-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :ptr :ptr :ptr :ptr :ptr))

(defn plscmap1l [itype intensity coord1 coord2 coord3 alt-hue-part]
  (assert (= (length intensity) (length coord1) (length coord2)
             (length coord3) (inc (length alt-hue-part))))
  (let [intensity-buf (double-buf intensity)
        coord1-buf (double-buf coord1)
        coord2-buf (double-buf coord2)
        coord3-buf (double-buf coord3)
        alt-hue-part-buf (int32-buf alt-hue-part)]
    (ffi/call c_plscmap1l c_plscmap1l-sig
              itype (length intensity) intensity-buf
              coord1-buf coord2-buf coord3-buf
              alt-hue-part-buf)))

# plscmap1la

(def- c_plscmap1la (ffi/lookup plplot-library "c_plscmap1la"))
(def- c_plscmap1la-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :ptr :ptr :ptr :ptr :ptr :ptr))

(defn plscmap1la [itype intensity coord1 coord2 coord3 alpha alt-hue-part]
  (assert (= (length intensity) (length coord1) (length coord2) (length coord3)
             (length alpha) (length alt-hue-part)))
  (let [intensity-buf (double-buf intensity)
        coord1-buf (double-buf coord1)
        coord2-buf (double-buf coord2)
        coord3-buf (double-buf coord3)
        alpha-buf (double-buf alpha)
        alt-hue-part-buf (int32-buf alt-hue-part)]
    (ffi/call c_plscmap1la c_plscmap1la-sig
              itype (length intensity) intensity-buf
              coord1-buf coord2-buf coord3-buf
              alpha-buf alt-hue-part-buf)))

# plscmap1n()

(def- c_plscmap1n (ffi/lookup plplot-library "c_plscmap1n"))
(def- c_plscmap1n-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plscmap1n [ncol1]
  (ffi/call c_plscmap1n c_plscmap1n-sig ncol1))

# plscmap1_range()

(def- c_plscmap1_range (ffi/lookup plplot-library "c_plscmap1_range"))
(def- c_plscmap1_range-sig
  (ffi/signature :default
                 :void
                 :double :double))

(defn plscmap1-range [min-color max-color]
  (ffi/call c_plscmap1_range c_plscmap1_range-sig min-color max-color))

# plscol0()

(def- c_plscol0 (ffi/lookup plplot-library "c_plscol0"))
(def- c_plscol0-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32 :int32))

(defn plscol0 [icol0 r g b]
  (ffi/call c_plscol0 c_plscol0-sig icol0 r g b))

# plscol0a()

(def- c_plscol0a (ffi/lookup plplot-library "c_plscol0a"))
(def- c_plscol0a-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32 :int32 :double))

(defn plscol0a [icol0 r g b alpha]
  (ffi/call c_plscol0a c_plscol0a-sig icol0 r g b alpha))

# plscolbg()

(def- c_plscolbg (ffi/lookup plplot-library "c_plscolbg"))
(def- c_plscolbg-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32))

(defn plscolbg [r g b]
  (ffi/call c_plscolbg c_plscolbg-sig r g b))

# plscolbga()

(def- c_plscolbga (ffi/lookup plplot-library "c_plscolbga"))
(def- c_plscolbga-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32 :double))

(defn plscolbga [r g b alpha]
  (ffi/call c_plscolbga c_plscolbga-sig r g b alpha))

# plscolor()

(def- c_plscolor (ffi/lookup plplot-library "c_plscolor"))
(def- c_plscolor-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plscolor [color]
  (ffi/call c_plscolor c_plscolor-sig color))

# plscompression()

(def- c_plscompression (ffi/lookup plplot-library "c_plscompression"))
(def- c_plscompression-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plscompression [compression]
  (ffi/call c_plscompression c_plscompression-sig compression))

# plsdev()

(def- c_plsdev (ffi/lookup plplot-library "c_plsdev"))
(def- c_plsdev-sig
  (ffi/signature :default
                 :void
                 :ptr))

(defn plsdev [device]
  (ffi/call c_plsdev c_plsdev-sig device))

# plsdidev()

(def- c_plsdidev (ffi/lookup plplot-library "c_plsdidev"))
(def- c_plsdidev-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double))

(defn plsdidev [mar aspect jx jy]
  (ffi/call c_plsdidev c_plsdidev-sig mar aspect jx jy))

# plsdimap()

(def- c_plsdimap (ffi/lookup plplot-library "c_plsdimap"))
(def- c_plsdimap-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32 :int32 :double :double))

(defn plsdimap [dimxmin dimxmax dimymin dimymax dimxpmm dimypmm]
  (ffi/call c_plsdimap c_plsdimap-sig
            dimxmin dimxmax dimymin dimymax dimxpmm dimypmm))

# plsdiori()

(def- c_plsdiori (ffi/lookup plplot-library "c_plsdiori"))
(def- c_plsdiori-sig
  (ffi/signature :default
                 :void
                 :double))

(defn plsdiori [rot]
  (ffi/call c_plsdiori c_plsdiori-sig rot))

# plsdiplt()

(def- c_plsdiplt (ffi/lookup plplot-library "c_plsdiplt"))
(def- c_plsdiplt-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double))

(defn plsdiplt [xmin ymin xmax ymax]
  (ffi/call c_plsdiplt c_plsdiplt-sig xmin ymin xmax ymax))

# plsdiplz()

(def- c_plsdiplz (ffi/lookup plplot-library "c_plsdiplz"))
(def- c_plsdiplz-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double))

(defn plsdiplz [xmin ymin xmax ymax]
  (ffi/call c_plsdiplz c_plsdiplz-sig xmin ymin xmax ymax))

# plsdrawmode()

(def- c_plsdrawmode (ffi/lookup plplot-library "c_plsdrawmode"))
(def- c_plsdrawmode-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plsdrawmode [mode]
  (ffi/call c_plsdrawmode c_plsdrawmode-sig mode))

# plseed()

(def- c_plseed (ffi/lookup plplot-library "c_plseed"))
(def- c_plseed-sig
  (ffi/signature :default
                 :void
                 :uint32))

(defn plseed [seed]
  (ffi/call c_plseed c_plseed-sig seed))

# plsesc()

(def- c_plsesc (ffi/lookup plplot-library "c_plsesc"))
(def- c_plsesc-sig
  (ffi/signature :default
                 :void
                 :char))

(defn plsesc [esc]
  (ffi/call c_plsesc c_plsesc-sig esc))

# plsfam()

(def- c_plsfam (ffi/lookup plplot-library "c_plsfam"))
(def- c_plsfam-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32))

(defn plsfam [fam num bmax]
  (ffi/call c_plsfam c_plsfam-sig fam num bmax))

# plsfci()

(def- c_plsfci (ffi/lookup plplot-library "c_plsfci"))
(def- c_plsfci-sig
  (ffi/signature :default
                 :void
                 :uint32))

(defn plsfci [fci]
  (ffi/call c_plsfci c_plsfci-sig fci))

# plsfnam()

(def- c_plsfnam (ffi/lookup plplot-library "c_plsfnam"))
(def- c_plsfnam-sig
  (ffi/signature :default
                 :void
                 :string))

(defn plsfnam [fnam]
  (ffi/call c_plsfnam c_plsfnam-sig fnam))

# plsfont()

(def- c_plsfont (ffi/lookup plplot-library "c_plsfont"))
(def- c_plsfont-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :int32))

(defn plsfont [family style weight]
  (ffi/call c_plsfont c_plsfont-sig family style weight))

# TODO: Requires callback
# 
# plshade()

# (def- c_plshade (ffi/lookup plplot-library "c_plshade"))
# (def- c_plshade-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :int32 :int32 :ptr :double :double :double :double
#                  :double :double :int32 :double :double :int32 :int32
#                  :int32 :int32 :ptr :int32 :ptr :ptr))

# TODO: Requires callback
# 
# plshades()

# (def- c_plshades (ffi/lookup plplot-library "c_plshades"))
# (def- c_plshades-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :int32 :int32 :ptr :double :double :double :double
#                  :ptr :int32 :double :int32 :double :ptr :int32 :ptr :ptr))

# TODO: Requires callback
# 
# plfshades()

# (def- plfshades (ffi/lookup plplot-library "plfshades"))
# (def- plfshades-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :int32 :int32 :ptr :double :double :double :double
#                  :ptr :int32 :double :int32 :double :ptr :int :ptr :ptr))

# TODO: Requires callback
# 
# plfshade()

# (def- plfshade (ffi/lookup plplot-library "plfshade"))
# (def- plfshade-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :double :double :double
#                  :double :double :double :int32 :double :double :int32 :int32
#                  :int32 :int32 :ptr :int32 :ptr :ptr))

# TODO: Requires callback
# 
# plfshade1()

# (def- plfshade1 (ffi/lookup plplot-library "plfshade1"))
# (def- plfshade1-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :int32 :int32 :ptr :double :double :double :double
#                  :double :double :int32 :double :double :int32 :double
#                  :int32 :double :ptr :int32 :ptr :ptr))

# TODO: Requires callback
# 
# plslabelfunc()

# (def- c_plslabelfunc (ffi/lookup plplot-library "c_plslabelfunc"))
# (def- c_plslabelfunc-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr))

# plsmaj()

(def- c_plsmaj (ffi/lookup plplot-library "c_plsmaj"))
(def- c_plsmaj-sig
  (ffi/signature :default
                 :void
                 :double :double))

(defn plsmaj [default-length scale]
  (ffi/call c_plsmaj c_plsmaj-sig default-length scale))

# plsmem()

(def- c_plsmem (ffi/lookup plplot-library "c_plsmem"))
(def- c_plsmem-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :ptr))

(defn plsmem [maxx maxy plotmem]
  (ffi/call c_plsmem c_plsmem-sig maxx maxy plotmem))

# plsmema()

(def- c_plsmema (ffi/lookup plplot-library "c_plsmema"))
(def- c_plsmema-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :ptr))

(defn plsmema [maxx maxy plotmem]
  (ffi/call c_plsmema c_plsmema-sig maxx maxy plotmem))

# plsmin()

(def- c_plsmin (ffi/lookup plplot-library "c_plsmin"))
(def- c_plsmin-sig
  (ffi/signature :default
                 :void
                 :double :double))

(defn plsmin [default-length scale]
  (ffi/call c_plsmin c_plsmin-sig default-length scale))

# plsori()

(def- c_plsori (ffi/lookup plplot-library "c_plsori"))
(def- c_plsori-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plsori [ori]
  (ffi/call c_plsori c_plsori-sig ori))

# plspage()

(def- c_plspage (ffi/lookup plplot-library "c_plspage"))
(def- c_plspage-sig
  (ffi/signature :default
                 :void
                 :double :double :int32 :int32 :int32 :int32))

(defn plspage [xp yp xleng yleng xoff yoff]
  (ffi/call c_plspage c_plspage-sig xp yp xleng yleng xoff yoff))

# plspal0()

(def- c_plspal0 (ffi/lookup plplot-library "c_plspal0"))
(def- c_plspal0-sig
  (ffi/signature :default
                 :void
                 :string))

(defn plspal0 [filename]
  (ffi/call c_plspal0 c_plspal0-sig filename))

# plspal1()

(def- c_plspal1 (ffi/lookup plplot-library "c_plspal1"))
(def- c_plspal1-sig
  (ffi/signature :default
                 :void
                 :string :int32))

(defn plspal1 [filename interpolate]
  (ffi/call c_plspal1 c_plspal1-sig filename interpolate))

# plspause() 

(def- c_plspause (ffi/lookup plplot-library "c_plspause"))
(def- c_plspause-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plspause [pause]
  (ffi/call c_plspause c_plspause-sig pause))

# plsstrm()

(def- c_plsstrm (ffi/lookup plplot-library "c_plsstrm"))
(def- c_plsstrm-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plsstrm [strm]
  (ffi/call c_plsstrm c_plsstrm-sig strm))

# plssub()

(def- c_plssub (ffi/lookup plplot-library "c_plssub"))
(def- c_plssub-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn plssub [nx ny]
  (ffi/call c_plssub c_plssub-sig nx ny))

# plssym()

(def- c_plssym (ffi/lookup plplot-library "c_plssym"))
(def- c_plssym-sig
  (ffi/signature :default
                 :void
                 :double :double))

(defn plssym [default-height scale]
  (ffi/call c_plssym c_plssym-sig default-height scale))

# plstar()

(def- c_plstar (ffi/lookup plplot-library "c_plstar"))
(def- c_plstar-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn plstar [nx ny]
  (ffi/call c_plstar c_plstar-sig nx ny))

# plstart()

(def- c_plstart (ffi/lookup plplot-library "c_plstart"))
(def- c_plstart-sig
  (ffi/signature :default
                 :void
                 :string :int32 :int32))

(defn plstart [devname nx ny]
  (ffi/call c_plstart c_plstart-sig devname nx ny))

# TODO: Requires callback

# (def- c_plstransform (ffi/lookup plplot-library "c_plstransform"))
# (def- c_plstransform-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr))

# plstring()

(def- c_plstring (ffi/lookup plplot-library "c_plstring"))
(def- c_plstring-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :string))

(defn plstring [x y str]
  (assert (= (length x) (length y)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)]
    (ffi/call c_plstring c_plstring-sig (length x) x-buf y-buf str)))

# plstring3

(def- c_plstring3 (ffi/lookup plplot-library "c_plstring3"))
(def- c_plstring3-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :ptr :string))

(defn plstring3 [x y z str]
  (assert (= (length x) (length y) (length z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-buf z)]
    (ffi/call c_plstring3 c_plstring3-sig
              (length x) x-buf y-buf z-buf str)))

# plstripa()

(def- c_plstripa (ffi/lookup plplot-library "c_plstripa"))
(def- c_plstripa-sig
  (ffi/signature :default
                 :void
                 :int32 :int32 :double :double))

(defn plstripa [id pen x y]
  (ffi/call c_plstripa c_plstripa-sig id pen x y))

# plstripc()

(def- c_plstripc (ffi/lookup plplot-library "c_plstripc"))
(def- c_plstripc-sig
  (ffi/signature :default
                 :void
                 :int32 :string :string :double :double :double :double
                 :double :double :double :int32 :int32 :int32 :int32
                 :ptr :ptr :ptr :string :string :string))

(defn plstripc [xspec yspec xmin xmax xjump ymin ymax xlpos ylpos
                y-ascl acc colbox collab colline styline
                legline labx laby labtop]
  (assert (= 4 (length colline) (length styline) (length legline)))
  (let [id-buf (ffi/write :int32 0)
        colline-buf (int32-buf colline)
        styline-buf (int32-buf styline)
        legline-buf (strings-buf legline)]
    (ffi/call c_plstripc c_plstripc-sig
              id-buf xspec yspec xmin xmax xjump ymin ymax
              xlpos ylpos y-ascl acc colbox collab
              colline-buf styline-buf legline-buf
              labx laby labtop)
    (ffi/read :int32 id-buf)))

# plstripd()

(def- c_plstripd (ffi/lookup plplot-library "c_plstripd"))
(def- c_plstripd-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plstripd [id]
  (ffi/call c_plstripd c_plstripd-sig id))

# TODO: Requires callback
# 
# plimagefr()

# (def- c_plimagefr (ffi/lookup plplot-library "c_plimagefr"))
# (def- c_plimagefr-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :int32 :int32 :double :double :double :double
#                  :double :double :double :double :ptr :ptr))

# TODO: Requires callback
# 
# plfimagefr()

# (def- c_plfimagefr (ffi/lookup plplot-library "c_plfimagefr"))
# (def- c_plfimagefr-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :int32 :int32 :double :double
#                  :double :double :double :double :double
#                  :double :ptr :ptr))

# plimage()

(def- c_plimage (ffi/lookup plplot-library "c_plimage"))
(def- c_plimage-sig
  (ffi/signature :default
                 :void
                 :ptr :int32 :int32 :double :double :double :double
                 :double :double :double :double :double :double))

(defn plimage [idata xmin xmax ymin ymax zmin zmax
               dxmin dxmax dymin dymax]
  (assert (every? (map (fn [row] (= (length (first idata)) (length row))) idata)))
  (let [idata-buf (double-matrix-buf idata)
        nx (length (first idata))
        ny (length idata)]
    (ffi/call c_plimage c_plimage-sig idata-buf nx ny
              xmin xmax ymin ymax zmin zmax
              dxmin dxmax dymin dymax)))

# TODO: Requires callback
# 
# plfimage()

# (def- plfimage (ffi/lookup plplot-library "plfimage"))
# (def- plfimage-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :int32 :int32  :double :double :double :double
#                  :double :double :double :double :double :double))

# plstyl()

(def- c_plstyl (ffi/lookup plplot-library "c_plstyl"))
(def- c_plstyl-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr))

(defn plstyl [mark space]
  (assert (= (length mark) (length space)))
  (let [nms (length mark)]
    (ffi/call c_plstyl c_plstyl-sig nms mark space)))

# plsurf3d()

(def- c_plsurf3d (ffi/lookup plplot-library "c_plsurf3d"))
(def- c_plsurf3d-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32 :int32 :int32 :ptr :int32))

(defn plsurf3d [x y z opt clevel]
  (assert (= (length y) (length z)))
  (assert (every? (map (fn [row] (= (length x) (length row))) z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-matrix-buf z)
        clevel-buf (double-buf clevel)]
    (ffi/call c_plsurf3d c_plsurf3d-sig
              x-buf y-buf z-buf (length x) (length y)
              opt clevel-buf (length clevel))))

# TODO: Requires callback
# 
# plfsurf3d()

# (def- plfsurf3d (ffi/lookup plplot-library "plfsurf3d"))
# (def- plfsurf3d-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :int32 :ptr :int32))

(def- c_plsurf3dl (ffi/lookup plplot-library "c_plsurf3dl"))
(def- c_plsurf3dl-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr :int32 :int32 :int32 :double :int32
                 :int32 :int32 :ptr :ptr))

(defn plsurf3dl [x y z opt clevel indexymin indexymax]
  (assert (= (length y) (length z)))
  (assert (every? (map (fn [row] (= (length x) (length row))) z)))
  (let [x-buf (double-buf x)
        y-buf (double-buf y)
        z-buf (double-matrix-buf z)
        clevel-buf (int32-buf clevel)
        indexymin-buf (int32-buf indexymin)
        indexymax-buf (int32-buf indexymax)]
    (ffi/call c_plsurf3dl c_plsurf3dl-sig
              x-buf y-buf z-buf (length x) (length y)
              opt clevel-buf (length clevel)
              (length indexymin) (length indexymax)
              indexymin-buf indexymax-buf)))

# TODO: Requires callback
# 
# plfsurf3dl()

# (def- plfsurf3dl (ffi/lookup plplot-library "plfsurf3dl"))
# (def- plfsurf3dl-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :ptr :int32 :int32 :int32 :ptr
#                  :int32 :int32 :int32 :ptr :ptr))

# plsvect()

(def- c_plsvect (ffi/lookup plplot-library "c_plsvect"))
(def- c_plsvect-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :int32 :int32))

(defn plsvect [arrowx arrowy fill]
  (assert (= (length arrowx) (length arrowy)))
  (let [arrowx-buf (double-buf arrowx)
        arrowy-buf (double-buf arrowy)]
    (ffi/call c_plsvect c_plsvect-sig 
              arrowx-buf arrowy-buf (length arrowx) fill)))

# plsvpa()

(def- c_plsvpa (ffi/lookup plplot-library "c_plsvpa"))
(def- c_plsvpa-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double))

(defn plsvpa [xmin xmax ymin ymax]
  (ffi/call c_plsvpa c_plsvpa-sig xmin xmax ymin ymax))

# plsxax()

(def- c_plsxax (ffi/lookup plplot-library "c_plsxax"))
(def- c_plsxax-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn plsxax [digmax digits]
  (ffi/call c_plsxax c_plsxax-sig digmax digits))

# plsxwin()

(def- c_plsxwin (ffi/lookup plplot-library "plsxwin"))
(def- c_plsxwin-sig
  (ffi/signature :default
                 :void
                 :int32))

(defn plsxwin [window-id]
  (ffi/call c_plsxwin c_plsxwin-sig window-id))

# plsyax()

(def- c_plsyax (ffi/lookup plplot-library "c_plsyax"))
(def- c_plsyax-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn plsyax [digmax digits]
  (ffi/call c_plsyax c_plsyax-sig digmax digits))

# plsym()

(def- c_plsym (ffi/lookup plplot-library "c_plsym"))
(def- c_plsym-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr :ptr :int32))

(defn plsym [x y code]
  (let [x-buf (double-buf x)
        y-buf (double-buf y)]
    (ffi/call c_plsym c_plsym-sig (length x) x-buf y-buf code)))

# plszax()

(def- c_plszax (ffi/lookup plplot-library "c_plszax"))
(def- c_plszax-sig
  (ffi/signature :default
                 :void
                 :int32 :int32))

(defn plszax [digmax digits]
  (ffi/call c_plszax c_plszax-sig digmax digits))

# pltext()

(def- c_pltext (ffi/lookup plplot-library "c_pltext"))
(def- c_pltext-sig
  (ffi/signature :default
                 :void))

(defn pltext []
  (ffi/call c_pltext c_pltext-sig))

# pltimefmt()

(def- c_pltimefmt (ffi/lookup plplot-library "c_pltimefmt"))
(def- c_pltimefmt-sig
  (ffi/signature :default
                 :void
                 :string))

(defn pltimefmt [fmt]
  (ffi/call c_pltimefmt c_pltimefmt-sig fmt))

# plvasp()

(def- c_plvasp (ffi/lookup plplot-library "c_plvasp"))
(def- c_plvasp-sig
  (ffi/signature :default
                 :void
                 :double))

(defn plvasp [aspect]
  (ffi/call c_plvasp c_plvasp-sig aspect))

# TODO: Requires callback
# 
# plvect()

# (def- c_plvect (ffi/lookup plplot-library "c_plvect"))
# (def- c_plvect-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :int32 :int32 :double :ptr :ptr))

# TODO: Requires callback
# 
# plfvect()

# (def- plfvect (ffi/lookup plplot-library "plfvect"))
# (def- plfvect-sig
#   (ffi/signature :default
#                  :void
#                  :ptr :ptr :ptr :int32 :int32 :double :ptr :ptr))

# plvpas()

(def- c_plvpas (ffi/lookup plplot-library "c_plvpas"))
(def- c_plvpas-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double :double))

(defn plvpas [xmin xmax ymin ymax aspect]
  (ffi/call c_plvpas c_plvpas-sig xmin xmax ymin ymax aspect))

# plvpor()

(def- c_plvpor (ffi/lookup plplot-library "c_plvpor"))
(def- c_plvpor-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double))

(defn plvpor [xmin xmax ymin ymax]
  (ffi/call c_plvpor c_plvpor-sig xmin xmax ymin ymax))

# plvsta()

(def- c_plvsta (ffi/lookup plplot-library "c_plvsta"))
(def- c_plvsta-sig
  (ffi/signature :default
                 :void))

(defn plvsta []
  (ffi/call c_plvsta c_plvsta-sig))

# plw3d()

(def- c_plw3d (ffi/lookup plplot-library "c_plw3d"))
(def- c_plw3d-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double :double :double
                 :double :double :double :double :double))

(defn plw3d [basex basey height xmin xmax ymin ymax zmin zmax alt az]
  (ffi/call c_plw3d c_plw3d-sig
            basex basey height xmin xmax ymin ymax zmin zmax alt az))

# plwidth()

(def- c_plwidth (ffi/lookup plplot-library "c_plwidth"))
(def- c_plwidth-sig
  (ffi/signature :default
                 :void
                 :double))

(defn plwidth [width]
  (ffi/call c_plwidth c_plwidth-sig width))

# plwind()

(def- c_plwind (ffi/lookup plplot-library "c_plwind"))
(def- c_plwind-sig
  (ffi/signature :default
                 :void
                 :double :double :double :double))

(defn plwind [xmin xmax ymin ymax]
  (ffi/call c_plwind c_plwind-sig xmin xmax ymin ymax))

# plxormod()

(def- c_plxormod (ffi/lookup plplot-library "c_plxormod"))
(def- c_plxormod-sig
  (ffi/signature :default
                 :void
                 :int32 :ptr))

(defn plxormod [mode status]
  (ffi/call c_plxormod c_plxormod-sig mode status))

# plgFileDevs()

(def- c_plgFileDevs (ffi/lookup plplot-library "plgFileDevs"))
(def- c_plgFileDevs-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr))

(defn plgFileDevs []
  (let [menustr-buf (buffer/new 0)
        devname-buf (buffer/new 0)
        ndev-buf (buffer/new 0)]
    (ffi/write :ptr (buffer/new-filled (* 100 (ffi/size :ptr))) menustr-buf)
    (ffi/write :ptr (buffer/new-filled (* 100 (ffi/size :ptr))) devname-buf)
    (ffi/write :int32 100 ndev-buf)
    (ffi/call c_plgFileDevs c_plgFileDevs-sig menustr-buf devname-buf ndev-buf)
    (let [menustr-arr (ffi/read :ptr menustr-buf)
          devname-arr (ffi/read :ptr devname-buf)
          ndev (ffi/read :int32 ndev-buf)
          menustrs @[]
          devnames @[]]
      (each i (range ndev)
        (array/push menustrs (ffi/read :string menustr-arr (* i (ffi/size :ptr))))
        (array/push devnames (ffi/read :string devname-arr (* i (ffi/size :ptr)))))
      [menustrs devnames])))

# plgDevs()

(def- c_plgDevs (ffi/lookup plplot-library "plgDevs"))
(def- c_plgDevs-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :ptr))

(defn plgDevs []
  (let [menustr-buf (buffer/new 0)
        devname-buf (buffer/new 0)
        ndev-buf (buffer/new 0)]
    (ffi/write :ptr (buffer/new-filled (* 100 (ffi/size :ptr))) menustr-buf)
    (ffi/write :ptr (buffer/new-filled (* 100 (ffi/size :ptr))) devname-buf)
    (ffi/write :int32 100 ndev-buf)
    (ffi/call c_plgDevs c_plgDevs-sig menustr-buf devname-buf ndev-buf)
    (let [menustr-arr (ffi/read :ptr menustr-buf)
          devname-arr (ffi/read :ptr devname-buf)
          ndev (ffi/read :int32 ndev-buf)
          menustrs @[]
          devnames @[]]
      (each i (range ndev)
        (array/push menustrs (ffi/read :string menustr-arr (* i (ffi/size :ptr))))
        (array/push devnames (ffi/read :string devname-arr (* i (ffi/size :ptr)))))
      [menustrs devnames])))

# plparseopts()

(def- c_plparseopts (ffi/lookup plplot-library "c_plparseopts"))
(def- c_plparseopts-sig
  (ffi/signature :default
                 :void
                 :ptr :ptr :int32))

(defn plparseopts [args]
  (let [argc @""
        argv @""
        remaining @[]]
    (buffer/push-uint32 argc :le (length args))
    (eachp [idx arg] args
      (ffi/write :ptr arg argv (* idx (ffi/size :ptr))))
    (ffi/call c_plparseopts c_plparseopts-sig argc argv (bor PL-PARSE-SKIP))
    (let [remaining-argc (ffi/read :int32 argc)]
      (each idx (range remaining-argc)
        (array/push remaining (ffi/read :string argv (* idx (ffi/size :ptr)))))
      remaining)))
