turtles-own [ infected? thirsty? thirst time-sick immunity water-source]
patches-own [ contaminated? ]
globals [ total sick healthy dead immune day iterations total-final-population average-final-population population-data population? continue?]

;SETUP PROCESS///////////////////////////////////////////////////////////////////
to setup
  clear-all                   ;Clear the model
  create-water-sources        ;Creates water patches
  setup-plots-and-graphs
  create-people
  extra-setup
  reset-iterations
  setup-path
  reset-ticks
end

;STEP PROCESS////////////////////////////////////////////////////////////////////
to step
  check-for-stop
  if continue? = true [
    update-people
    move-turtles
    check-thirst
    extra-functionality
    check-contamination
    decrement-sickness
    decrement-immunity
    count-populations
    update-destinations
    reset-check
    tick
  ]


end



;###############################################################################
;######################### HELPER FUNCTIONS BELOW ##############################
;###############################################################################

to check-for-stop
  if Run-Multiple = true [
    if iterations >= Stop-Cycle [
      set continue? false
    ]
  ]
end

;Add a reset check and run it in intervals of
to setup-path
  set download-path "c:/Users/wesmu/Desktop/plot.csv"
end

to download-plot
  export-plot "Final Healthy Populations" download-path
end

to default-setup
  set Initial-Population 100
  set Initial-People-Infected 1
  set Initial-People-Immune 10
  set Decontamination-Chance 15
  set Day-Length 75
  set Max-Immunity 200
  set Infection-Duration 200
  set Travelers-Per-Day 5
  set Run-Multiple true
  set Stop-Cycle 500
end

to update-destinations
  if ticks mod day-length = 0 [
    let Updated-Travelers Travelers-Per-Day
    if Updated-Travelers > (total - dead)[
      set Updated-Travelers (total - dead)
    ]
    ask n-of Updated-Travelers turtles [
      set water-source (1 + (random (4)))
    ]
  ]
end

to setup-plots-and-graphs
  set population-data []
end

to reset-check
  let sick-patches (count patches with [contaminated? = true])
  if sick = 0 and sick-patches = 0 [;if simulation is done

    if Run-Multiple = true [
      let new-population (healthy)
      set population-data lput new-population population-data;;Add to histogram
      ;show population-data
      set total-final-population total-final-population + new-population
      ifelse iterations = 0 [
        set average-final-population 0
      ]                     [
        set average-final-population (total-final-population / iterations)
      ]

      ask turtles [ die ];kill all turtles
      create-people
      extra-setup
      set iterations (length population-data)
    ]

    ;EXPORT GRAPH

  ]
end


to count-populations
  set healthy (count turtles with [infected? = false and immunity <= 0])
  set immune (count turtles with [infected? = false and immunity > 0])
  set sick (count turtles with [infected? = true])
  set total (healthy + sick + dead + immune)
end

;TODO
to decrement-sickness
  ask turtles with [infected? = true][
    if color != red [
      set color red
    ]
    ifelse time-sick > Infection-Duration [
      ;Check if dies. 25-50% chance
      let random-chance ((random 25) + 25)
      let random-val (random 100)
      ifelse(random-val < random-chance)[;Dies if under the chance
        set dead (dead + 1)
        die
      ][
        set infected? false
        set immunity Max-Immunity
      ]
    ][
      set time-sick (time-sick + 1)

    ]
  ]

end

to decrement-immunity
  ask turtles with [immunity > 0][
    set immunity (immunity - 1)
  ]
end

to extra-functionality
  if ticks mod day-length = 0 [set day (day + 1)]
end

to extra-setup
  set day 0

end

to reset-iterations
  set iterations 0
  set total-final-population 0
  set population? false
  set continue? true
end

to move-turtles                 ;moves turtles ;show 1 + (random (4))

  ;When people are NOT thirsty
  ask turtles with [thirsty? = false][
  rt random 90
  lt random 90
  forward 0.5
  set thirst thirst + 1
  ]

  ;When people ARE thirsty
  ask turtles with [thirsty? = true][
    ;IF DRINKING WATER (Standing on water patch)
    if pcolor = blue or pcolor = orange[
      set thirsty? false
      set thirst (random 200)
      ; Check if you get infected from drinking the water
      if pcolor = orange and infected? = false[
        let randval (random Max-Immunity)
        if randval > immunity [
          set infected? true
          set time-sick (random Infection-Duration)
          set immunity 0
        ]
      ]
      ;If you are infected and drinking from a clean water source, make it infected
      if pcolor = blue and infected? = true[
        set contaminated? true
      ]
    ]
    ;Face them towards one of the four water patches
    if water-source = 1 [
      face patch 12 12
    ]
    if water-source = 2 [
      face patch -12 12
    ]
    if water-source = 3 [
      face patch 12 -12
    ]
    if water-source = 4 [
      face patch -12 -12
    ]
    ;face min-one-of patches with [ pcolor = blue or pcolor = orange ] [ distance myself ]
    forward 0.5
  ]
end

to check-contamination
  ask patches with [ contaminated? = true][

    if pcolor != orange [
      set pcolor orange
    ]

    ;DF 14
    let tmp Decontamination-Chance
    let val random-float tmp
    if val <= 1.0 [
        ;print date
        set contaminated? false
        set pcolor blue
    ]
  ]
end

to check-thirst
  ask turtles with [thirst > day-length][
    set thirsty? true
  ]
end

to create-water-sources        ;Creates water patches
  ask patch 12 12 [
    set pcolor blue
    set contaminated? false
  ]
    ask patch 12 -12 [
    set pcolor blue
    set contaminated? false
  ]
    ask patch -12 12 [
    set pcolor blue
    set contaminated? false
  ]
    ask patch -12 -12 [
    set pcolor blue
    set contaminated? false
  ]
end

to create-people               ;Creates people

  ; Create turtles
  create-turtles Initial-Population [
    set infected? false
    setxy random-xcor random-ycor
    set color yellow
    set thirsty? false
    set thirst (random 200)
    set immunity 0
    set water-source (1 + (random (4)))
  ]

  ;Set variables for counting populations
  set total Initial-Population
  set dead 0
  set sick 0
  set average-final-population 0

  ; Set some turtles to be infected
  ask n-of Initial-People-Infected turtles [
    set infected? true
    set sick Initial-People-Infected
  ]

  ;Create some people that are immune
  ask n-of Initial-People-Immune turtles with [infected? = false][
    set immunity (random Max-Immunity)
  ]

  ;Set healthy population count
  set healthy (total - sick)

end

to update-people              ;Update people's colors and values
  ask turtles with [infected? = true][
    set color red
  ]

  ask turtles with [infected? = false][
    ifelse immunity <= 0 [set color yellow][set color cyan]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
147
10
683
547
-1
-1
10.353
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
9
10
149
88
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
88
149
167
NIL
step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
166
150
245
run
step
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1159
389
1301
422
Initial-People-Infected
Initial-People-Infected
0
Initial-Population
1.0
1
1
NIL
HORIZONTAL

MONITOR
9
304
150
365
Healthy Population
healthy
17
1
15

MONITOR
9
244
150
305
Total Population
total
17
1
15

MONITOR
9
365
150
426
Infected Population
sick
17
1
15

MONITOR
9
425
150
486
Death Count
dead
17
1
15

SLIDER
1159
357
1301
390
Initial-Population
Initial-Population
0
250
201.0
1
1
NIL
HORIZONTAL

PLOT
683
10
1440
271
Populations vs Time
Time
Population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot total"
"Healthy" 1.0 0 -1184463 true "" "plot healthy"
"Sick" 1.0 0 -2674135 true "" "plot sick"
"Dead" 1.0 0 -4539718 true "" "plot dead"
"Immune" 1.0 0 -11221820 true "" "plot immune"

MONITOR
9
486
149
547
Day
day
17
1
15

SLIDER
1159
421
1301
454
Initial-People-Immune
Initial-People-Immune
0
Initial-Population
193.0
1
1
NIL
HORIZONTAL

SWITCH
921
579
1030
612
Run-Multiple
Run-Multiple
0
1
-1000

PLOT
683
271
1159
579
Final Healthy Populations
Final Population Count
Population Frequency
0.0
200.0
0.0
200.0
true
false
"set-plot-x-range 0 1\n;set-plot-x-range 0 Initial_Population\nset-plot-y-range 0 100\n;set-plot-y-range 0 max population-data\nset-histogram-num-bars 25" "ifelse (length population-data) = 0 \n[set-plot-x-range 0 100]\n[set-plot-x-range 0 (max population-data)]\nset-histogram-num-bars 25"
PENS
"default" 1.0 1 -16777216 true "" "histogram population-data"

MONITOR
683
579
814
624
Average Final Population
mean population-data
0
1
11

MONITOR
814
579
922
624
Total Cycles
iterations
17
1
11

SLIDER
1311
426
1469
459
Day-Length
Day-Length
0
250
75.0
1
1
Days
HORIZONTAL

TEXTBOX
1206
285
1356
316
VARIABLES
25
0.0
1

BUTTON
1339
284
1450
317
DEFAULT VARIABLES
default-setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1312
357
1470
390
Decontamination-Chance
Decontamination-Chance
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
1159
486
1301
519
Infection-Duration
Infection-Duration
0
250
150.0
1
1
NIL
HORIZONTAL

SLIDER
1159
453
1301
486
Max-Immunity
Max-Immunity
0
250
200.0
1
1
NIL
HORIZONTAL

TEXTBOX
1191
333
1341
354
HUMAN
17
14.0
1

TEXTBOX
1356
333
1506
354
WATER
17
105.0
1

TEXTBOX
1334
405
1455
426
ENVIRONMENT
17
33.0
1

SLIDER
1158
518
1301
551
Travelers-Per-Day
Travelers-Per-Day
0
Initial-Population
5.0
1
1
NIL
HORIZONTAL

BUTTON
1300
636
1432
669
DOWNLOAD PLOT
download-plot
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1252
669
1469
729
download-path
c:/Users/wesmu/Desktop/plotg3.csv
1
0
String

INPUTBOX
1030
579
1159
639
Stop-Cycle
750.0
1
0
Number

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
