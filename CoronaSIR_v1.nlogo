;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; variables individuelles : caractéristiques de chaque personne (turtle)
turtles-own
  [ malade?                ;; si égale à 0 -> la personne est saine,
                           ;; si égale à 1 -> la personne est infectée
                           ;; si égale à 2 -> la personne es guérie et immune
    temps_malade           ;; depuis combien de jours la personne est infectée
    temps_immune           ;; depuis combien de jours la personne est est immune
  ]
;; variables globales : caractéristiques de la population
globals
  [ proba_Infect          ;; probabilité de devenir infecté par contact sain-malade
    N_contacts ncj ncj-1  ;; nombre de contacts entre personnes (ncj ncj1 : variables pour compter le nombre de contacts par jour)
    N_expos  nej nej-1    ;; nombre de contacts entre personnes sanes <-> malades  (nej : nombre d'expositions par jour)
    %saines               ;; pourcentage de population saine
    %infectes             ;; pourcentage de population infectéé
    %immunes              ;; pourcentage de population guérie
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization du modèle
to setup
  clear-all                  ;; mise à zéro de toutes les variables
  setup-turtles              ;; lecture des caractéristiques individuelles et initialization de la population
  setup-global               ;; lecture des caractéristiques et initialization de la population
  update-global-variables    ;; mise à jour des variables globales
  reset-ticks
end
;; initialization de la population
to setup-turtles
  create-turtles N_personnes                           ;; création de N personnes
    [ setxy random-xcor random-ycor          ;; dispersion des personnes au hasard
      set shape "person"
      set size 1                             ;; taille grande, pour faciliter la visualisation
      set malade? 0                          ;; toutes les personnes sont sanes
      set color green                        ;; toutes les personnes sont sanes (couler)
      set temps_malade 0                     ;; toutes les personnes sont sanes (0 jours infectés)
      set temps_immune 0               ;; toutes les personnes sont susceptibles d'être contagiées (0 jours dimmunite)
      ]
  ask n-of 1 turtles                         ;; choisir une personne au hasard
    [contagion ]                             ;; 1 personnes initiallement infectée
end

;; initialisation des variables globales
to setup-global
  ask patches [set pcolor white]              ;; fond d'écran blanc pour faciliter la visualisation
  set proba_Infect  %infectiosité             ;; lecture de la probabilité de tomber malade a chaque contact avec une autre personne
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEROULEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  step
end

to step
  ask turtles [
    move
    if malade? = 1 [infecter
                    set temps_malade temps_malade + 1
                    guérir_ou_perir
                   ]
    if malade? = 2 [perte_immunite?]
  ]
  tick
  update-global-variables
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mouvement: se déplacer à une case voisine au hasard
to move                                  ;;  routine per cada personne
  rt random 100                          ;; tourner à droite un angle au hasard
  lt random 100                          ;; tourner à gauche un angle au hasard
  fd 1                                   ;;  avancer d'une case
  ask other turtles-here                 ;; pour toutes les personnes dans la même case à ce jour...
  [set N_contacts N_contacts + 1]        ;; ... compter le nombre de contactes par jour
end


;; infection : par contact avec les personnes dans la même case, avec une probabilité "proba_Infect"
to infecter                                     ;;  routine per cada personne
  ask other turtles-here with [ malade? = 0 ]   ;; pour toutes les personnes saines dans la même case à ce jour...
    [ set N_expos N_expos + 1                   ;; ... compter le nombre d'expositions par jour. Puis,...
      if random-float 100 < proba_Infect        ;; ... si la chance est inférieur à la probabilité de s'infecter ...
      [ contagion ] ]                           ;; ... la pesronne devient infectée
end
;; dévenir malade
to contagion              ;;  routine per cada personne
  set malade? 1           ;;  la pesronne est malade
  set color red
end
;; se guérir
to guérir_ou_perir                             ;;  routine per cada personne
  ;;;; a introuduir la mortalité -> plus tard
  if temps_malade > durée_infection [guerison]          ;;  la pesronne est malade
end

;; guerison
to guerison               ;; routine per cada personne
  set malade? 2           ;; la personne est immunisée
  set temps_malade 0      ;; mise à zéro de la durée de maladie
  set color blue
end
;; perte d'immunitée
to perte_immunite?           ;; routine per cada personne
  ifelse temps_immune > durée_immunité
  [ set malade? 0           ;; la personne est susceptible
  set color green]
  [set temps_immune temps_immune + 1]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to update-global-variables
  set ncj N_contacts - ncj-1
  set ncj-1 N_contacts
  set nej N_expos - nej-1
  set nej-1 N_expos

  if count turtles > 0
    [ set %infectes (count turtles with [ malade? = 1 ] / count turtles) * 100
      set %immunes (count turtles with [ malade? = 2 ] / count turtles) * 100
      set %saines  100 - %immunes - %infectes
     ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
29
408
92
441
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

SLIDER
26
13
198
46
N_personnes
N_personnes
0
5000
2420.0
1
1
NIL
HORIZONTAL

SLIDER
40
152
196
185
%infectiosité
%infectiosité
0
100
18.0
1
1
NIL
HORIZONTAL

INPUTBOX
41
187
196
247
durée_infection
15.0
1
0
Number

INPUTBOX
42
249
197
309
durée_immunité
1000.0
1
0
Number

BUTTON
95
408
150
441
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
153
408
208
441
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

PLOT
649
202
1053
448
Nombre de personnes
Jours
Pourcentage
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"saines" 1.0 0 -10899396 true "" "plot %saines"
"infectes" 1.0 0 -2674135 true "" "plot %infectes"
"immunes" 1.0 0 -13345367 true "" "plot %immunes"

MONITOR
650
152
710
197
NIL
%saines
1
1
11

MONITOR
712
152
782
197
NIL
%infectes
1
1
11

MONITOR
784
152
847
197
NIL
%immunes
1
1
11

MONITOR
684
102
848
147
%Expositions_par_Contact
nej / ncj * 100
1
1
11

MONITOR
650
11
767
56
N(contacts/pers/J)
ncj / count turtles
0
1
11

MONITOR
650
56
767
101
N(Expositions/pers/J)
nej / count turtles
0
1
11

MONITOR
770
11
847
56
N(contacts/j)
ncj
0
1
11

MONITOR
769
57
848
102
N(expos/j)
nej
0
1
11

PLOT
852
10
1052
199
Contacts par personne
Jour
N(contacts)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot ncj / count turtles"
"Expo." 1.0 0 -2064490 true "" "plot nej / count turtles"

MONITOR
82
50
198
95
Densité population
count turtles / count patches
2
1
11

MONITOR
27
49
77
94
taille
count patches
0
1
11

@#$#@#$#@
#############################################################################
## C'EST QUOI CE MODELE ?
##( description générale de ce que le modèle essaie d'expliquer)
#############################################################################

Le modèle Corona_SIR simule la transmission et perpetuation d'un virus (p.ex. le coronavirus) à une échelle journalière dans une population humaine homogène et mixée. 
Il distingue trois états d'infection: sain (S), infecfté /infectieus (I) et Récupéré / guéri (R) 


#############################################################################
## COMMENT çA MARCHE ? 
##(principe et règles généralles de fonctionnement)
#############################################################################

Le modèle est initialisé avec N personnes, dont 1 est infectée. Les gens se déplacent au hasard dans un monde ouvert.

Les personnes peuvent être dans l'un des trois états d'infection : en bonne santé mais sensible aux infections (vert), malades et infectieux (rouge) et en bonne santé et immunisé (bleu). 

Les gens saines devienent peuvent dévenir malades lorsque elles sont dans la même case qu'une persone infectée. Les gens malades se guérissent et deviennent immunes à la fin d'une infection. 

D'autres aspects du modèle sont détaillés ci-dessous. Chaque ligne du code est commentée. 
#############################################################################
## COMMENT UTILISER LE MODELE 
##(Guide et description des éléments dans l'interface)
#############################################################################

#> A GAUCHE DE L'INTERFACE: LES CONTREÔLES DU SIMULATEUR
> N_personnes : choisir la taille de la population.
> N_cases : indique la taille du modèle
> Densité population : indique le nombre de personnes par case, en moyenne
> %infectiosité : choisir la probabilité d'infection (en %) lorsque deux personnes sont dans la même case
> durée_infection : choisir le nombre de jours pendant lesquels une personne malade reste infectieuse
> durée_immunitée : choisir le nombre de jours pendant lesquels une personne guérie reste immunisée à la maladie
> setup : initialisation de la simulation
> go : lancer la simulation en continu
> step : avancer la simulation, jour par jour.

 
#> AU MILLIEU DE L'INTERFACE: L'AFFICHAGE DU SIMULATEUR
> Contôle de vitesse d'affichage ( par défaut : 1 tick = 1 jour)
> Carré de taille 33 x 33 = 1089 cases. Le monde est ouvert : une personne qui sort d'un côté du carrée entre automatiquement par le côté opposé. 
> Console : pour écrire des lignes de code qui seront executées par le simulateur instantannément 
> Code : transcription litérale et exhaustive du code de simulation
> Information : renseignements sur le modèle et le simulateur.


#> A DROITE : AFFICHAGE DES SOERTIES GRAPHIQUES ET NUMERIQUES
> N(contacts/pers/J)= Nombre de contacts par personne et par jour
> N(contacts/J)= Nombre total de contacts par jour
> N(expositions/pers/J)= Nombre de contacts entre une personne saine et une personne infectée par personne et par jour
> N(exposs/J)= Nombre total de contacts entre une personne saine et une personne infectée par jour
> %Expositions par contact: Pourcentage des contacts journalmiers qui ont lieu entre une personne saine et une personne infectée. 
> Graphique 1 : contacts par personne. 
>>N(contacts/pers/J): ligne noire et 
>>N(expositions/pers/J): ligne rouge.  
> %saines : pourcentage de personnes saines
> %infectess : pourcentage de personnes malades
> %immunes : pourcentage de personnes gueries et immunisées
> Graphique 2 : Pourcentage de personnes dans chaque état d'infection.
>> %saines : ligne verte, 
>> %infectées : ligne rouge.  
>> %immunes : ligne bleue.  


#############################################################################
##  À ESSAYER 
## (ce que l'utilisateur peut faire lors de l'exécution du modèle) 
#############################################################################

> Faire varier les paramèrtres d'entrée du simulateur à l'aide des buttons de contrôle 
(nombre de personnes, infectiosité, durée de l'infection, durée de l'immunité).

> Observer comment varient les pourcentages de personnes saines, malades et immunisées en fonction des paramètres d'entrée du simulateur. 


#############################################################################
## À NOTER 
## (ce que l'utilisateur doit remarquer lors de l'exécution du modèle)
#############################################################################

> Le mouvement des personnes provoque qu'elles rentrent en contact les unes avec les autres, d'où la propagation de la maladie.

> Lorsque le nombre de personnes augmente, la densité de population (nobre de personnes par case, en moyenne) augmente à son tour. Plus la densité de population est élévée, plus les contacts entre personnes sont fréquents, et plus facilement la maladie se propage. 

> Si l'infectiosité augmente, la maladie se propage plus rapidement et le pourcentage de personnes malade augmente plus vite.

> Si la durée d'infection augmente, la maladie se propage plus rapidement et le pourcentage de personnes malade augmente plus vite.

> A mesure que nombre de personnes malades augmente (et à mesure que les mlalades guérissen et deviennent immunisés) il y a moins de personnes saines susceptibles d'être infectées. Le pourcentage de personnes malades au cours du temps (ligne rouge sur le graphique 2) dessine une courbe en forme de montagne. On appelle cette courbe la corbe de l'épidémie. Au sommet de cette montagne, lorsque le pourcentage de malades est le plus grande, on dit qu'on est arrivé au pic de l'épidémie.  

> Une fois passée le pic de l'épidemie, majorité de la population est immunisée et  le nombre de malades diminue progressivement. L'épidemie finit par s'epuiser d'elle même.

> Si la durée d'immunité est trop petite, l'épidémie peut recommencer : on a des épidémies saisonières, comme la gripe.  


#############################################################################
## ÉTENDRE LE MODÈLE 
## (ce que un administrateur peut faire pour améliorer modèle) 
#############################################################################

> Le coronavirus est une maladie mortelle. Il faudrait introduir une modèle pour la mortalité dans nôtre modèle.

> Il faudrait introduir des mécanismes pour modéliser les mesures permettant de réduire le nombre de contacts entre personnes : p. ex. : le confinement.

#############################################################################
## MODÈLES CONNEXES 
## (comment ce modèele est liée à d'autres versions)
#############################################################################

> Pour comprendre les notions basiques du modèle de la population homogène mixée, ainsi que les fondamentaux du mouvement des personnes, consulter les versions précédentes: "Modèle Population". 

> Pour approfondir sur la modélisation de la propagation du coronavirus, consulter les versions plus élaborées du modèle "Corona_SIR"


#############################################################################
## CRÉDITS ET RÉFÉRENCES
#############################################################################

Ce modèle aété conçu et réalisé par : 
Jordi Ferrer. Professeur de Physique Chimie. 
CGE Léon Gambetta. Paris. Le 03/04/2020.

Version actuelle modifié par Jordi
Jordi Ferrer. Professeur de Physique Chimie. 
CGE Léon Gambetta. Paris. Le 03/04/2020.
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
NetLogo 6.1.1
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
