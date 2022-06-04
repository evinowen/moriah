![Moriah](/docs/BoIR.Moriah.Title.png "Moriah")

moriah
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

### Items
Moriah adds 13 different collectibles, both active and passive.

See the Binding of Isaac wiki for more details about this collectible type:
https://bindingofisaacrebirth.fandom.com/wiki/Items
#### **BAKER'S APRON**
![Baker's Apron](/resources/gfx/items/collectibles/bakers_apron.png "Baker's Apron")

> "Bake me a cake as fast as you can"

**Item Pool**

```
Treasure Room
```

**Quality**

★★★★☆

**Effects**
- Enrolls Isaac in the Baking trade, as Isaac recovers health he gains experience with Baking.
- Isaac is able to improve his skill and achieve Journeyman, Master, and Grandmaster status with this trade.
- Higher skill levels increase the rate duration and magnitude of the Tears bonus granted by the apron.
- The Baking trade grants a bonus to Isaac's Tears, ranging from +0.5 Tears to +1.5 Tears, depending on how much health has been recovered recently.

![Baker's Apron](/gifs/bakers_apron.gif "Baker's Apron")

#### **BOW TIE**
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

![Bow Tie](/gifs/bowtie.gif "Bow Tie")

#### **BUTCHER'S APRON**
![Butcher's Apron](/resources/gfx/items/collectibles/butchers_apron.png "Butcher's Apron")

> "How could you be so mean?"

**Item Pool**

```
Treasure Room
```

**Quality**

★★★★☆

**Effects**
- Enrolls Isaac in the Butchering trade, as Isaac deals damage he gains experience with Butchering.
- Isaac is able to improve his skill and achieve Journeyman, Master, and Grandmaster status with this trade.
- Higher skill levels increase the rate duration and strength of the Damage bonus granted by the apron.
- The Butchering trade grants a bonus to Isaac's Damage, ranging from +0.5 Damage to +1.5 Damage, depending on how much damage has been dealt recently.

![Butcher's Apron](/gifs/butchers_apron.gif "Butcher's Apron")

#### **CHANDLER'S APRON**
![Chandler's Apron](/resources/gfx/items/collectibles/chandlers_apron.png "Chandler's Apron")

> "Jack be nimble, Jack be quick"

**Item Pool**

```
Treasure Room
```

**Quality**

★★★★☆

**Effects**
- Enrolls Isaac in the Chandlering trade, as Isaac recharges his active item he gains experience with Chandlering.
- Isaac is able to improve his skill and achieve Journeyman, Master, and Grandmaster status with this trade.
- Higher skill levels increase the rate duration and magnitude of the Shot Speed bonus granted by the apron.
- The Chandlering trade grants a bonus to Isaac's Shot Speed, ranging from +0.5 Shot Speed to +1.5 Shot Speed, depending on how much charge has been grained recently.

![Chandler's Apron](/gifs/chandlers_apron.gif "Chandler's Apron")

#### **THE COFFEE BEAN**
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

![The Coffee Bean](/gifs/coffee_bean.gif "The Coffee Bean")

#### **EGGS**
![Eggs](/resources/gfx/items/collectibles/eggs.png "Eggs")

> "6-Pack!"

**Recharge Time**

90 seconds

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

![Eggs](/gifs/eggs.gif "Eggs")

#### **FISHBOWL**
![Fishbowl](/resources/gfx/items/collectibles/fishbowl.png "Fishbowl")

> "blub blub blub"

**Item Pool**

```
Secret Room
```

**Quality**

★★★☆☆

**Effects**
- Isaac wears Fishbowl on their head, grants flight.
- Tears and Projectiles bounce off Fishbowl, causing no damage to Isaac.
- While wearing the Fishbowl, Isaac is unable to fire tears, as they are also blocked by the Fishbowl.

![Fishbowl](/gifs/fishbowl.gif "Fishbowl")

#### **HELIUM**
![Helium](/resources/gfx/items/collectibles/helium.png "Helium")

> "I be a wee little Leprechaun!"

**Recharge Time**

360 seconds

**Item Pool**

```
Treasure Room
```

**Quality**

★★★☆☆

**Effects**
- Upon use inflates a Helium Balloon that follows Isaac.
- While Isaac holds three Helium Balloons, grants flight.
- If Isaac takes damage while holding a Helium Balloon, the Helium Balloon will pop and prevent Isaac from taking the damage.

![Helium](/gifs/helium.gif "Helium")

#### **HYMNAL**
![Hymnal](/resources/gfx/items/collectibles/hymnal.png "Hymnal")

> "Bored again Christian"

**Recharge Time**

6 rooms

**Item Pool**

```
Treasure Room
Library
```

**Quality**

★★★☆☆

**Effects**
- Upon use Isaac sings a Hymn that freezes all Enemies in the room.

![Hymnal](/gifs/hymnal.gif "Hymnal")

#### **LUNCHBOX**
![Lunchbox](/resources/gfx/items/collectibles/lunchbox.png "Lunchbox")

> "Stay Fresh!™"

**Recharge Time**

8 rooms

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

![Lunchbox](/gifs/lunchbox.gif "Lunchbox")

#### **OIL LAMP**
![Oil Lamp](/resources/gfx/items/collectibles/oil_lamp.png "Oil Lamp")

> "I've got the black lung, pop."

**Item Pool**

```
Secret Room
```

**Quality**

★★★☆☆

**Effects**
- Spawns a floating Oil Lamp familiar that can be fired towards enemies as a projectile.
- Oil Lamp is fired directly from where it is located in the chain of familiars behind Isaac, similar to Bob's Brain. (https://bindingofisaacrebirth.fandom.com/wiki/Bob%27s_Brain)
- If an Oil Lamp makes contact with a Fire Place (https://bindingofisaacrebirth.fandom.com/wiki/Fire_Places), the Oil Lamp is lit and assumes the same fire variation as the Fire Place it made contact with.

![Oil Lamp](/gifs/oil_lamp.gif "Oil Lamp")

#### **PLANT**
![Plant](/resources/gfx/items/collectibles/plant.png "Plant")

> "plaaaaant"

**Item Pool**

```
Treasure Room
```

**Quality**

★★★☆☆

**Effects**
- Spawns a potted Plant familiar, which in its initial stage has not sprouted.
- The potted Plant will absorb enemy projectiles when they collide with the potted plant.
- After the Plant absorbs five projectiles, it will sprout.
- After the Plant absorbs ten projectiles, it will become fully grown.

![Plant](/gifs/plant.gif "Plant")

#### **WHISTLE**
![Whistle](/resources/gfx/items/collectibles/whistle.png "Whistle")

> "Rock you like a Whirlwind"

**Recharge Time**

3 rooms

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

![Whistle](/gifs/whistle.gif "Whistle")

### Trinkets
There are two trinkets added by the Moriah mod, the "Oven Mitt" and "Tissues".

See the Binding of Isaac wiki for more details about this collectible type:
https://bindingofisaacrebirth.fandom.com/wiki/Trinkets
#### **OVEN MITT**
![Oven Mitt](/resources/gfx/items/trinkets/oven_mitt.png "Oven Mitt")

> "Play with fire"

**Effects**
- While holding an Oven Mitt, Isaac is able to walk through fire without being damaged.

![Oven Mitt](/gifs/oven_mitt.gif "Oven Mitt")

#### **TISSUES**
![Tissues](/resources/gfx/items/trinkets/tissues.png "Tissues")

> "Dry your tears"

**Effects**
- While held, Isaac is unable to fire tears, and will instead occasionally drop tissues.
- If Isaac is in close proximity to enemy creep while holding Tissues, the enemy creep will be removed.

![Tissues](/gifs/tissues.gif "Tissues")

### Cards and Runes
Currently Moriah implements one additional card, the "Old Maid".

See the Binding of Isaac wiki for more details about this collectible type:
https://bindingofisaacrebirth.fandom.com/wiki/Cards_and_Runes
#### **OLD MAID**
![Old Maid](/content/gfx/ui_cardfront.big.old_maid.png "Old Maid")

**Effects**
- Exchanges the value of the pickups on the floor of the room for damage dealt to the enemies within it.
- Every pickup on the floor is exchanged for 5 damage for each cent of value.
- Pickups are valued based on the same rules as the Shop (https://bindingofisaacrebirth.fandom.com/wiki/Shop)
- If held, the Old Maid will provide important reminders as Isaac moves between rooms.

![Old Maid](/gifs/old_maid.gif "Old Maid")

### Transformations
Moriah has a single transformation, the "Tradesman".  This is state is achieved by collecting all three tradesmen apron passive collectibles.

See the Binding of Isaac wiki for more details about this collectible type:
https://bindingofisaacrebirth.fandom.com/wiki/Transformations
#### **TRADESMAN**

> "Butcher, Baker, Candlestick Maker"

Collect all three of the tradesman aprons to become the "Tradesman".

**Effects**
- Grants flight.
- Spawns a Butcher's Cleaver familiar that orbits Isaac, similar to [Sacrificial Dagger](https://bindingofisaacrebirth.fandom.com/wiki/Sacrificial_Dagger)
- Isaac's tears are now thrown from a candle on the top of his head, and inflict burn on enemies.

![Tradesman](/gifs/tradesman.gif "Tradesman")

