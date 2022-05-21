﻿moriah
======
A mod for The Binding of Isaac: Repentance

Build
------
Run `scripts\build.ps1` to create a deployable copy of the mod.

This is a required step because of the way that Lua files are included during the development process.  Essentially,
**The Binding of Isaac: Repentance** does not support reloading any mod files except for `main.lua`. To circumvent this
limitation, independent files are maintained for each object and concatenated into a single source `main.lua` file to be
deployed to the mod directory of the game.

Deploy
------
Run `scripts\deploy.ps1` to copy the directory contents to the appropriate Steam directory for **The Binding of Isaac: Repentance** mods.

Catalog
------
Below in an index of all added items contained in this modification.  Thank you, and please enjoy!

### **BOW TIE**
![Bow Tie](/resources/gfx/items/collectibles/bowtie.png "Bow Tie")

> "HP up + you feel charming"

**Item Pool**

```
Treasure Room
```

**Quality**

★★☆☆☆

**Effects**
- Adds one Red Heart Container.
- Adds a 10% chance to shoot a Charm tear.

### **THE COFFEE BEAN**
![The Coffee Bean](/resources/gfx/items/collectibles/coffee_bean.png "The Coffee Bean")

> "Speed Up"

**Item Pool**

```
Beggar
Treasure Room
```

**Quality**

☆☆☆☆☆

**Effects**
- Grants +0.25 speed.
- When taking damage, Isaac poops.
  - Icaac has a 10% change to poop a Corny Poo.

### **EGGS**
![Eggs](/resources/gfx/items/collectibles/eggs.png "Eggs")

> "6-Pack!"

**Item Pool**

```
Beggar
Treasure Room
```

**Quality**

★☆☆☆☆

**Effects**
- Upon use when the Egg Carton has Eggs, Isaac holds the Eggs and can reuse the item to put them away again.
- While holding the Egg Carton, Isaac can fire an Egg using regular tear controls.
  - Eggs have Knockback and Bait, which will mark the Enemy it hits.
  - Throwing an Egg will remove one egg from the Egg Carton.
    - When all six Eggs have been thrown, Isaac will be left with an empty Egg Carton.
- Upon use when the Egg Carton is empty, Isaac will eat the Egg Carton and recover one red heart.

### **FISHBOWL**
![Fishbowl](/resources/gfx/items/collectibles/fishbowl.png "Fishbowl")

> "blub blub blub"

**Item Pool**

```
Secret Room
```

**Quality**

★★★☆☆

**Effects**
- Player wears Fishbowl on their head, grants flight.
- Tears and Projectiles bounce off Fishbowl, causing no damage to the wearer.
- The wearer of the Fishbowl is unable to fire tears, as they are also blocked by the Fishbowl.

### **HELIUM**
![Helium](/resources/gfx/items/collectibles/helium.png "Helium")

> "I be a wee little Leprechaun!"

**Item Pool**

```
Treasure Room
```

**Quality**

★★★☆☆

**Effects**
- Upon use inflates a Helium Balloon that follows Isaac.

### **HYMNAL**
![Hymnal](/resources/gfx/items/collectibles/hymnal.png "Hymnal")

> ""

**Item Pool**

```
Treasure Room
Library
```

**Quality**

★★★☆☆

**Effects**
- Upon use Isaac sings a Hymn that freezes all Enemies in the room.

### **LAMP**
![Lamp](/resources/gfx/items/collectibles/lamp.png "Lamp")

> ""

**Item Pool**

```
```

**Quality**

★★★☆☆

**Effects**

### **LUNCHBOX**
![Lunchbox](/resources/gfx/items/collectibles/lunchbox.png "Lunchbox")

> "Stay Fresh!™"

**Recharge Time**

8 Rooms

**Item Pool**

```
Secret Room
```

**Quality**

★★☆☆☆

**Effects**
- Upon use Isaac holds the Lunchbox, and can reuse the item to put it away again.
- When held, colliding with a pickup will consume the Lunchbox item, and produce a Lunchbox familiar.
- When the player presses and holds the drop button, the Lunchbox familiar will open, destroying it and revealing the pickup the player previously collided with.

### **PLANT**
![Plant](/resources/gfx/items/collectibles/plant.png "Plant")

> ""

**Item Pool**

```
```

**Quality**

★★★☆☆

**Effects**

### **TISSUES**
![Tissues](/resources/gfx/items/trinkets/tissues.png "Tissues")

> ""

**Item Pool**

```
```

**Quality**

★★★☆☆

**Effects**

### **WHISTLE**
![Whistle](/resources/gfx/items/collectibles/whistle.png "Whistle")

> "Rock you like a Whirlwind"

**Recharge Time**

4 Rooms

**Item Pool**

```
Treasure Room
```

**Quality**

★★★★☆

**Effects**
- Upon use, play the Whistle.
- Once played, will reveal the floor dungeon if it is in the current room, otherwise the Whirlwind is summoned.
- When summoned, the Whirlwind enters the screen from the left and continues across it horizontally until it exits on the right.
- When the Whirlwind collides with an enemy, deals 40 damage.
- When the Whirlwind collides with a player, teleports player to a random room.

