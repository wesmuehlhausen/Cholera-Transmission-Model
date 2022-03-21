turtles-own [age thirsty? thirst infected? days-contagious]
patches-own [contaminated? ]
globals [date death-count]

;////////////////////////////////////////////////////////////////////////////////
;SETUP PROCESS///////////////////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////
to setup
  clear-all
  create-turtles-initially
  create-water-sources
  initial-person-and-resivoir-infection
  check-contamination
  other-setup
  reset-ticks

end

;////////////////////////////////////////////////////////////////////////////////
;STEP PROCESS////////////////////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////

; TODO
;- Look up more on how it is spread person-to-person and the rates
;


to step
  move-turtles
  check-thirst
;  move-people ; moves people to random xy
   age-people  ; Ages people one day
   birth-death-people ; Births and Kills people
   check-drinks-water ; Checks to see if a healthy person drinks water
   check-person-to-person-contact
   decrement-sickness
;  ;decrement-disease-in-water
  check-contamination
;  decrease-pathogen-lifetime-in-water
  check-days
  tick
end

;////////////////////////////////////////////////////////////////////////////////




to check-days
  if ticks mod thirst-level = 0 [set date date + 1]
end




to test-setup
  create-turtles 1 [
    set shape "circle"
    set color yellow
    setxy 0 0
  ]
end

to test-step
  ask turtles with [color = yellow][
    ask patches in-radius 5 [
      set pcolor yellow
    ]
    ask turtles in-radius 5 [
      set color yellow
    ]
  ]

end

to other-setup
  set date 0
  set death-count 0
end

to create-water-sources
  ask n-of water-patches patches [
    set pcolor blue
  ]
end

; Create a number of turtles
to create-turtles-initially
  create-turtles initial-population [
    set infected? false
    set thirsty? true
    set thirst thirst-level
    set color green
    move-to one-of patches
    ;set shape "circle"
  ]
end

to move-turtles
  ask turtles with [thirsty? = false][
  rt random 90
  lt random 90
  forward 0.5
  set thirst thirst + 1
  ]
  ask turtles with [thirsty? = true][
    drink-water
    face min-one-of patches with [ pcolor = blue or pcolor = orange ] [ distance myself ]
    forward 0.5
  ]

end

to drink-water
  if pcolor = blue or pcolor = orange[
    set thirsty? false
    set thirst 0
  ]
end

to check-thirst
  ask turtles with [thirst > thirst-level][
    set thirsty? true
  ]
end

;Have every turtle look for a water patch when they get thirsty for half the day
;Have them wander around for the other half of the day






















to decrease-pathogen-lifetime-in-water

end

;TODO Add Incubation period
to check-person-to-person-contact
  ask turtles with [infected? = true][
    ask turtles in-radius 2[
      if infected? = false [
        set color red
        set infected? true
        set days-contagious 7
      ]
    ]
  ]
end

;TODODODO
to decrement-sickness
  ask turtles with [infected? = true][
    set color red

    ;33% chance of death
    let tmp 4 * (thirst-level * 10)
    let val random-float tmp
    if val <= 1.0 [
      die
      set death-count death-count + 1
      print death-count
    ]

    ;66% chance they survive
    set tmp 6 * thirst-level
    set val random-float tmp
    if val <= 1.0[
      set infected? false
      set days-contagious 0
      set color green
    ]

  ]
end

to check-drinks-water
  ask turtles with [pcolor = orange and infected? = false][
    set color red
    set infected? true
    set days-contagious 7
  ]
  ask turtles with [pcolor = blue and infected? = true][
    set pcolor orange
    set contaminated? true
  ]
end


to initial-person-and-resivoir-infection
  ask n-of percent-water-infected patches [
    set contaminated? true
    set pcolor orange
  ]
end

to check-contamination
  ask patches with [ contaminated? = true][

    if pcolor != orange [
      set pcolor orange
    ]

    ;1/14 chance of losing pathogen
    let tmp 14 * thirst-level
    let val random-float tmp
    if val <= 1.0 [
        ;print date
        set contaminated? false
        set pcolor blue
    ]
  ]
end

; Asks all turtles to hatch or die based on rates
to birth-death-people
  ask turtles [
    let val random-float 365.1
    if val <= 0.044 [
      hatch 1 [
        setxy random-xcor random-ycor
      ]
    ]
    if val <= 0.033 [
      die
    ]
  ]

end

to move-people
  ask turtles [
    setxy random-xcor random-ycor
  ]
end

to age-people
  ask turtles [
    set age age + 1
  ]
end





; Need to have people moving randomly throughout the screen. For each step,
; If one person lands next to someone who is sick, try it out.
; If someone lands in a patch of water, and they are sick, then they can infect the water.
@#$#@#$#@
GRAPHICS-WINDOW
210
10
723
524
-1
-1
5.0
1
10
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
ticks
30.0

BUTTON
6
10
207
43
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
6
44
207
77
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
6
78
206
111
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
6
113
207
146
birth-rate
birth-rate
0
100
88.0
44
1
NIL
HORIZONTAL

SLIDER
342
553
514
586
water-patches
water-patches
0
1000
732.0
1
1
NIL
HORIZONTAL

SLIDER
342
590
514
623
initial-population
initial-population
0
1000
739.0
1
1
NIL
HORIZONTAL

SLIDER
516
554
695
587
percent-water-infected
percent-water-infected
0
100
38.0
1
1
NIL
HORIZONTAL

PLOT
732
11
1467
521
Populations
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
"Infected" 1.0 0 -2674135 true "" "plot count turtles with [infected? = true]"
"Healthy" 1.0 0 -13345367 true "" "plot count turtles with [infected? = false]"
"Dead" 1.0 0 -16777216 true "" "plot death-count"

PLOT
8
374
208
524
Water
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -955883 true "" "plot count patches with [pcolor = orange]"
"pen-1" 1.0 0 -13345367 true "" "plot count patches with [pcolor = blue]"

MONITOR
0
321
57
366
Healthy
count turtles with [infected? = false]
0
1
11

MONITOR
60
321
120
366
Infected
count turtles with [infected? = true]
0
1
11

SLIDER
516
590
688
623
thirst-level
thirst-level
0
250
57.0
1
1
NIL
HORIZONTAL

MONITOR
51
221
108
266
Days
date
0
1
11

MONITOR
125
322
182
367
Deaths
death-count
0
1
11

MONITOR
10
271
177
316
Total People
count turtles + death-count
17
1
11

@#$#@#$#@
## WHAT IS IT?

-Cholera is a diarrhoeal disease that is caused by an intestinal bacterium
-Goal: Minimize the disease related mortality and reduce the associated costs

## HOW IT WORKS

SIWR Model: (TODO Plot these rates)
S - Susceptible
I - Infectious
W - Waterborn Pathogen Concentration
R - Recovered

Added Modifications
q - Immunity loss term for recovered rate (TODO)
d - disease related death (TODO)

Other Variables 
V(t) - the rate of susceptible individuals being vaccinated per unit of time (TODO)
b1 - Spread rate via person-to-person contact (TODO)
nd - natural death rate (COMPLETED)
nb - natural birth rate (COMPLETED)
wr - Wane rate of effectiveness vs the vaccine (TODO)
yr - Rate of disease related recoveries (TODO)
a - Rate in which infected individuals shed pathogens in water (TODO)
er - Rate in which pathogens decay in water (COMPLETE)

Additional Rules
- Only those persons who receive two-doses of vaccines are included in the recovered class (TODO)
- assume the vaccine provides the same strength of immunity as had by those individuals who have recovered (TODO)

Ideas and things to include
- Could have variables adjusted by sliders and then introduce values found in the paper to see if the cost actually goes down
- Could introduce a ML mode where the model tries to figure it out itself
- Need to include a price of vaccination and see which variables will lessen it
- Ask how the waterborn part of it is spread - Pretty sure that most people get it through drinking water


## TYPES OF AGENTS IN MODEL

- The only type of agent in the model will be human turtles. A lot of the other variables will be turtle own variables
- Different human models would include susceptible, infectious, recovered

## PROPERTIES OF AGENTS

- The properties will be the variables listed above

## Behaviors of the model

 - The main behavior of the model would be people moving around and transfering the disease to eachother
 - Birth
 - Death
 - Movement

# TODO: 
- sketch a block diagram of the predator-prey model in NetLogo (Priority)
	- "That is the most important task right now. If you can get further in the 			  videos, that great, but focus on the code."
- Understand El Farol model really well (Potentially)
- Look at equations from 2.1 from the paper (Continue) file:///C:/Users/wesmu/Downloads/effectVaccinesCholera.pdf and plug in Endemic/Introduced variables in and see how it results


## HOW TO USE IT



## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
