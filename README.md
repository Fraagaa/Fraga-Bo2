# Fraga-Bo2

## Game Changes

- Backspeed fixed
- Zombie health fix
- Animated Skyboxes
- Night mode
- Player shadows

## HUD CHANGES

    Game timer
    Round timer
    Trap timer
    SPH meter (default start at 30)
    HUD color and position can be changed
    Round Splits

## MAP CHANGES

Tranzit

    Bank full for all players
    All perman perks are given on spawn to all players
    MP5 upgraded on weapon locker for all players
    
Town

    Box is set to double tap
    
Die Rise

    Bank full for all players
    All perman perks are given on spawn to all players
    AN94 upgraded on the weapon locker for all players
    Trample steam counter
    
Mob of the Dead

    Trap timer
    Box set to cafeteria always
    Key always spawns at cafeteria
    
Buried

    Bank full for all players
    All perman perks are given on spawn to all players
    AN94 upgraded on the weapon locker for all players
    Animated pap camo
    Tramplesteam, turbine and resonator counters

Origins

    Box set to gen 2
    Wunderfizz set to gen 4
    Animated pap camo

## Splits

Round 5: Rounds 1,2,3,4,5

Round 30: Rounds 5, 10, 15, 20, 25, 30

Round 50: Rounds 10, 20, 30, 40, 50

Round 70: Rounds 10, 20, 30, 40, 50, 60, 70

Round 100: Rounds 30, 50, 70, 80, 90, 100

Round 150: Rounds 50, 70, 100, 125, 130, 140, 150

Round 200: Rounds 50, 70, 100, 150, 175, 200

SR **RoundNumeber** (you need to do a fast_restart):
Example: SR 30

## DVars

character 1 2 3 4 5

    1 = Misty, Richtophen, Arlington
    2 = Russman, Dempsei, Finn
    3 = Marlton, Nikolai, Sal
    4 = Stuthlinger, Takeo, Billy
    5 = Ghost (mob)

splits 1 0

    Shows/hides splits

firstbox 1 0

    Disables RNG from the box until round 10

sph

     What round sph starts showing, default is 30
    
timer 1 0

     Enables timer, default is enabled

round_timer 1 0

    Enables round timer, default is enabled

traptimer 1 0

    Enables trap timer, default is disabled
    
timerx and timery

    Changes timer position
    
color "x x x"

    Changes timer color (RGB format)
    
buildables 0 1

    Shows/Hides the buildables menu on Die Rise / Buried

SR

    5 30 50 70 100 150 200

## Useful binds

* bind o "toggle buildables 0 1"
* bind 7 "toggle traptimer 0 1"
* bind 8 "toggle firstbox 1 0"
* bind N "toggle night_mode 1 0"
