(import ../plplot/plplot :as pl)

# Display all available devices and the corresponding nice string

(printf "Available devices for the -dev command line option and plsdev()")
(printf "")
(printf (string/format "%12s -- %s" "Device" "Menu String"))
(printf "      ------ -- -----------")
(let [[menustrs devstrs] (pl/plgDevs)]
  (each s (map (fn [a b] (string/format "%12s -- %s" a b)) devstrs menustrs)
    (printf "%s" s)))