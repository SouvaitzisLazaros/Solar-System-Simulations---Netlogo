breed [ planets ]

;TURTLES' VARIABLES

turtles-own [ 
  mass 
  Vx Vy 
  aX aY 
  x y 
  radius avg-radius radius-ratio 
  y_old 
  orbitcount 
  t_label 
  GForce    ]

;GLOBAL VARIABLES

globals [ 
  sun earth mars mercury venus jupiter saturn uranus neptune 
  time 
  scale 
  G     ]

to setup
  
    display
   
    clear-all
    clear-output
       
    set Zoom 15
    set scale 1
    set scale Zoom * max-pxcor / 150
    set time Speed
    set G 6.673 * 10 ^ (0 - 11)     ;Gravitation constant in units of newton*m^2/kg^2 converted to units of Astronomical Units, 
                                    ;planet masses are measured in earth masses
    crt 1
    create-planets 9                ;turtle 9 is the comet --> might be affected by other planets (Sun, Jupiter, Saturn) if it gets close enough
                                    
   
   
   
    ask turtles [set shape "circle"]
   
   
    ;INITIALIZING PLANETS
   
   
    set sun turtle 0
    ask sun [
        set color yellow + 1
        set mass 329390 
        set t_label "Sun "
        ;set scale 5
        set size (log 1391900 10) / 2
        ]
    
    
    set mercury turtle 1
    ask mercury [
        set mass .0549 
        set avg-radius 0.388 / 3
        set t_label "Mer "
        set color brown
        set size (log 4866 10) / 2 
        ]
    
    set venus turtle 2
    ask venus [
        set mass .8073 
        set avg-radius .722 / 3
        set t_label "V "
        set color orange - 1
        set size (log 12106 10) / 2
        ]
    
    set earth turtle 3
    ask earth [
        set mass 1 
        set avg-radius 1.00 / 3
        set t_label "E "
        set color blue
        set size (log 12742 10) / 2
        ]
    set mars turtle 4
    ask mars [
        set mass .1065 
        set avg-radius 1.53 / 2
        set t_label "M "
        set color red
        set size (log 6760 10) / 2
        ]
    set jupiter turtle 5
    ask jupiter [
        set mass 314.5 
        set avg-radius 5.2 / 3
        set t_label "J "
        set color yellow - 2
        set size (log 142984 10) / 2
        ]
    
    set saturn turtle 6
    ask saturn [
        set mass 94.07 
        set avg-radius 9.54 / 3
        set t_label "S "
        set color brown + 2
        set size (log 116438 10) / 2
        ]    
    
    set uranus turtle 7
    ask uranus [
       set mass 14.536 
       set avg-radius 19.18 / 3
       set t_label "U "
       set color sky + 1
       set size (log 46940 10) / 2
       ]
    
    set neptune turtle 8
    ask neptune [
       set mass 17.147 
       set avg-radius 30.06 / 3
       set t_label "N "
       set color turquoise
       set size (log 45432 10) / 2
       ]
    
    ;comet
    ask turtle 9 [
        set mass Comet_Mass
        set avg-radius Comet_Start          ;comet's initial position at distance from sun specified by the slider
        set color white 
        set t_label "Com "
        set x avg-radius 
        set y 0  
        set size (log Comet_Diameter 10) / 2
        
                            
        ]
    
    
   ;INITIAL POSITION & VELOCITY
  
                            
   ;planets are randomly positioned, except for the comet, but at the correct distance from the sun, in Astromonical Units.  Masses are in earth-masses.
   ;x and y are used for coordinates, and then scaled 

    ask planets with [who < 9][
      
                ifelse random 2 = 0 
                    [set x random-float avg-radius]
                    [set x 0 - random-float avg-radius] 
                    
                ifelse random 2 = 0 
                    [set y sqrt (avg-radius ^ 2 - x ^ 2)]
                    [set y 0 - sqrt (avg-radius ^ 2 - x ^ 2)]
                 ]
    
    ask planets [
      
                ifelse abs (x * scale) > max-pxcor or abs (y * scale) > max-pxcor 
                    [set hidden? true setxy x * scale y * scale]
                    [set hidden? false setxy x * scale y * scale]
                ] 

    ask planets [set radius sqrt(x ^ 2 + y ^ 2) ]
    
    
    ifelse ViewLabels = false 
        [ask turtles [set label ""]]
        [ask planets [set label t_label]]

    
        
    
    ;initial velocity : a = v^2/r for tangential velocity and a = -G*M/r^2. Solve for V at x = r.  Then V = -sqrt(G*M/r).
    ask planets with [who < 9][
      
        set Vy sqrt (([mass] of sun * G) / radius) * sin ((towards-nowrap sun) - 180)         ;to get the correct sign of V for every quadrant we use :
        set Vx 0 - sqrt (([mass] of sun * G) / radius) * cos ((towards-nowrap sun) - 180)     ;sin ((towards-nowrap sun) - 180) and cos ((towards-nowrap sun) - 180)
         ]
         
    ask turtle 9 [
        set Vx 0    ;We suppose the initial Vx = 0
                           
        ;Vx = 0 ---> always at -90 degrees due to Sun, so always: sin ((towards-nowrap sun) - 180) = -270           
        ;Higher Comet_Ellipticity --> more elliptical orbit       
        set Vy sqrt (([mass] of sun * G) / radius) * sin (-270) * ((100 - Comet_Ellipticity) / 100) 
            ]
         
        ;compute acceleration in x and y directions due to sun's gravity 
    ask planets [
      
        set aX 0 - ((x * [mass] of sun * G) / radius ^ 3) 
        set aY 0 - ((y * [mass] of sun * G) / radius ^ 3)
         ]
         
        ;compute acceleration in x and y directions due to gravities of other planets
    
                ask planets [
                  
                    ask planets with [who != [who] of myself] [
                      
                        set aX [aX] of myself - (((mass * G ) * ([x] of myself - x))/(sqrt ( (x - [x] of myself ) ^ 2 + (y - [y] of myself) ^ 2)) ^ 3)
                        set aY [aY] of myself - (((mass * G ) * ([y] of myself - y))/(sqrt ( (x - [x] of myself ) ^ 2 + (y - [y] of myself) ^ 2)) ^ 3)
                                                              ]
                            ]
                 
      
    ;we use average velocity, with acceleration applied for t/2 seconds.
    
    ask planets [
                set Vx Vx + aX * time / 2 
                set Vy Vy + aY * time / 2
                ]
                
    initial_Plots
    
    reset-ticks
end


;GO BUTTON

to Go
   IsRuning
end


;SIMULATION RUN

to IsRuning
    set scale Zoom * max-pxcor / 150
    
    ;compute new positions for all orbiting bodies
    ask planets [                                
                set x x + Vx * time  
                set y y + Vy * time
                
                
     ;hide turtle IF new position is off-screen
                ifelse abs (x * scale) > max-pxcor or abs (y * scale) > max-pxcor 
                    
                    [set hidden? true]
                    [set hidden? false 
                     setxy x * scale y * scale]
                    
                    
                set radius sqrt(x ^ 2 + y ^ 2)
                
     ;new accelerations based on sun's gravity
                set aX 0 - ((x * [mass] of sun * G) / radius ^ 3) 
                set aY 0 - ((y * [mass] of sun * G) / radius ^ 3)
                ]
    
     
     ;compute new velocities
    ask planets [        
                set Vx Vx + aX * time 
                set Vy Vy + aY * time
                ]
                
                
                
     ;on/off visible labels           
    ifelse ViewLabels = false                     
        [ask turtles [set label ""]]
        [ask planets [set label t_label]]
        
  
    
     ;keep track of number of orbits each planet makes
    ask planets [               
        if y_old < 0 and y > 0 
            [set orbitcount orbitcount + 1]
             set y_old y
                ]
                
   
    
    ;keeping track of ratio of current radius to initial average radius for comet and earth. These are beeing used for the plots below.
    ask earth [set radius-ratio ((radius  / (avg-radius)))]
    ask turtle 9 [set radius-ratio ((radius  / (avg-radius)))]
    
    ask turtle 9 [set GForce (mass * 329390 * G ) / (radius-ratio ^ 2)]

    if Plotting = true [PlotSetup]
end         
         
         
         
;PLOTTING PROCEDURES         
            
to PlotSetup
  
  set-current-plot "Comet - Sun Distance"
  ask turtle 9 [set-current-plot-pen "radius-ratio turtle 9"]
  ask turtle 9 [plot radius-ratio]
  
  set-current-plot "Comet - Earth Distance"
  ask turtle 9 [set-current-plot-pen "comet-earth"]
  ask turtle 9 [plot [radius-ratio] of turtle 9 - [radius-ratio] of Earth ]
  
  set-current-plot "Comet - GForce"
  ask turtle 9 [set-current-plot-pen "Gforce turtle 9"]
  ask turtle 9 [plot GForce]
  
end


to initial_Plots
  
  set-current-plot "Comet - Sun Distance"
  set-plot-y-range 0 1.2
  set-plot-x-range 0 1000
  
  set-current-plot "Comet - Earth Distance"
  set-plot-y-range 0 1.2
  set-plot-x-range 0 1000
  
  
end


               
@#$#@#$#@
GRAPHICS-WINDOW
422
10
1116
725
85
85
4.0
1
10
1
1
1
0
1
1
1
-85
85
-85
85
0
0
1
ticks
30.0

BUTTON
18
53
192
128
Setup
Setup
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
232
53
405
129
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1126
340
1386
491
Comet - Sun Distance
Time
Distance/Init. Distance
0.0
10.0
1.6
100.0
true
false
"" ""
PENS
"radius-ratio turtle 9" 1.0 0 -16777216 true "" ""

MONITOR
1121
25
1207
70
Earth years
[orbitcount] of earth
0
1
11

SWITCH
18
303
123
336
ViewLabels
ViewLabels
1
1
-1000

SLIDER
17
176
189
209
Zoom
Zoom
1
100
15
1
1
NIL
HORIZONTAL

SLIDER
17
220
190
253
Speed
Speed
1
10
3
1
1
NIL
HORIZONTAL

SWITCH
18
262
122
295
Plotting
Plotting
0
1
-1000

SLIDER
234
218
406
251
Comet_Ellipticity
Comet_Ellipticity
0
100
71
1
1
NIL
HORIZONTAL

SLIDER
233
177
405
210
Comet_Start
Comet_Start
1.6
40
17.3
0.1
1
AU
HORIZONTAL

SLIDER
234
260
406
293
Comet_Diameter
Comet_Diameter
1000
4000
1150
50
1
NIL
HORIZONTAL

MONITOR
1122
127
1210
172
Neptune years
[orbitcount] of Neptune
17
1
11

PLOT
1125
185
1383
335
Comet - Earth Distance
time
Distance/Init. Distance
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"comet-earth" 1.0 0 -16777216 true "" ""

PLOT
1126
499
1388
698
Comet - GForce
time
N ~ (e22 - e25)
0.0
10.0
0.0
0.05
true
false
"" ""
PENS
"Gforce turtle 9" 1.0 0 -16777216 true "" ""

SLIDER
234
303
406
336
Comet_Mass
Comet_Mass
0.003
50
0.653
0.05
1
NIL
HORIZONTAL

MONITOR
1122
78
1208
123
Jupiter years
[orbitcount] of Jupiter
17
1
11

@#$#@#$#@
Interface	

Η διεπαφή του μοντέλου χωρίζεται σε τρεις περιοχές. Αριστερά βρίσκονται τα εργαλεία παραμετροποίησης της προσομοίωσης (control panel), τα κουμπιά ελέγχου, οι διακόπτες καθώς και οι επιλογείς αρχικών τιμών. Στο κέντρο βρίσκεται το περιβάλλον αλληλεπίδρασης του μοντέλου (world) δηλαδή το σύνολο των πλανητών σε τροχιά γύρω από τον Ήλιο. Στα δεξιά παρουσιάζονται οι γραφικές παραστάσεις (που αφορούν τον κομήτη) και μετρητές.





Control Panel

Το γραφικό περιβάλλον αναπαριστά την κίνηση των πλανητών, αλλά προκειμένου να είναι δυνατόν να δωθούν οι αληθινές αποστάσεις (υπό κλίμακα), χρειάζεται η δυνατότητα μεγέθυνσης (σμίκρυνσης) της προσομοίωσης για να μπορούν να παρατηρηθούν επαρκώς όλοι οι πλανήτες, που επιτυγχάνεται μέσω του slider «zoom» . Το slider «speed» έχει αντίστοιχο ρόλο με τον speed slider του interface tab της NetLogo, δίνοντας πρόσθετο εύρος ταχυτήτων προσομοίωσης. 
‘Επειτα υπάρχουν δύο διακόπτες: ο 1ος ενεργοποιεί/απενεργοποιεί τη εμφάνιση γραφικών παραστάσεων στα δεξιά, ενώ ο 2ος ενεργοποιεί/απενεργοποιεί την εμφάνιση των συντομογραφιών των πλανητών στην προσομοίωση. 
 Οι βασικότερες παραμετροποιήσεις της προσομοίωσης είναι αυτές που αφορούν τον κομήτη. Ο επιλογέας «Comet_Start» δίνει την αρχική θέση (απόσταση από τον ‘Ηλιο) του κομήτη σε AU (1AU = απόσταση Γης-Ήλιου). Ο 2ος επιλογέας «Comet_Ellipticity» καθορίζει το πόσο ελλειπτική θα είναι η τροχιά του κομήτη (όσο μεγαλύερος ο παράγοντας τόσο πιο ελλειπτική τροχιά). Ο 3ος επιλογέας ρυθμίζει τη διάμετρο του κομήτη, παράγοντας που δεν επηρεάζει την προσομοίωση. Ο τελευταίος και καθοριστικός επιλογέας είναι αυτός της μάζας του κομήτη (σε Γήινες μάζες), όπου για διαφορετικές τιμές του μπορεί να αλλάζει εντελώς η αλληλεπίδραση πλανητών-κομήτη. 
Παρακάτω φένεται το εν λόγω control panel. 





Plots/Monitors

Αρχικά έχουμε τρεις μετρητές (monitors) οι οποίοι μετράνε το σύνολο των τροχιών (έτη) τριών χαρακτηριστικών πλανητών, της Γης, του Δία και του Ποσειδώνα. Η επιλογή αυτών έγινε για να είναι αισθητή η διαφορά του χρόνου περιστροφής του πλανήτη μας με σε σχέση με τον Δία που βρίσκεται σε μια μέση απόσταση από τον Ήλιο και του Ποσειδώνα που είναι ο πιο απομακρυσμένος πλανήτης του ηλιακού μας συστήματος.
Έπειτα ακολουθούν τα διαγράμματα που αφορούν τον κομήτη. Το 1ο διάγραμμα «Comet – Earth Distance» απεικονίζει το ρυθμό μεταβολής της απόστασης του κομήτη από τη Γη σε σχέση με την αρχική τους απόσταση. Το 2ο διάγραμμα «Comet – Sun Distance» απεικονίζει το ρυθμό μεταβολής της απόστασης του κομήτη από τον Ήλιο και πάλι σε σχέση με την αρχική απόσταση μεταξύ τους. Το 3ο διάγραμμα «Comet GForce» παρουσιάζει την μεταβολή στη βαρυτική δύναμη που δημιουργείται από τον ‘Ηλιο και τον κομήτη. 







@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

asteroid
true
0
Polygon -7500403 true true 90 120 75 150 90 180 105 180 120 210 135 225 195 225 225 180 225 150 210 120 180 90 180 120 165 75 120 60 90 75 75 105 90 120

bee
true
0
Polygon -1184463 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7500403 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
Polygon -16777216 true false 115 70 129 74 128 223 114 224
Polygon -16777216 true false 89 67 74 71 74 224 89 225 89 67
Polygon -16777216 true false 43 91 31 106 31 195 45 211
Line -1 false 200 144 213 70
Line -1 false 213 70 213 45
Line -1 false 214 45 203 26
Line -1 false 204 26 185 22
Line -1 false 185 22 170 25
Line -1 false 169 26 159 37
Line -1 false 159 37 156 55
Line -1 false 157 55 199 143
Line -1 false 200 141 162 227
Line -1 false 162 227 163 241
Line -1 false 163 241 171 249
Line -1 false 171 249 190 254
Line -1 false 192 253 203 248
Line -1 false 205 249 218 235
Line -1 false 218 235 200 144

bird1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 5.0.5
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
