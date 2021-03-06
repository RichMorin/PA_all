# Raspberry Pi 3 B+ CanaKit Assembly

*Note:*
As an [AmazonSmile]{https://smile.amazon.com} affiliate,
I will earn a commission on any products
purchased by following links from this page.
My commission does not affect the price you pay for the product.
It does, however, enable me to continue my work of bringing
affordable computers, accessible to the blind, to everyone everywhere.

Would you like to have a blind-accessible Linux system,
based on the [Raspberry Pi 3 B+ CanaKit](https://www.amazon.com/dp/B07V5JTMV9?tag=stormdragon29-20),
but haven’t dared to build one yourself?
Follow this HowTo and you won't get lost.

*Note:*
Much of this material is also covered in my YouTube video,
[Raspberry Pi 3 B+ Kit Assembly](https://www.youtube.com/watch?v=7vIlP4NYTWE).

## Selection

If you haven't already made your selection, this might be a good time
to consider your options.
If you want a faster and more powerful system,
a Raspberry Pi 4 B (with 4 GB of RAM) might be a good choice.
Also, the fact that the Raspberry Pi 4 B CanaKit has a fan
provides a blind-accessible way to know that the system is powered up.
On the down side, the 4B draws more power
and will thus have a shorter battery lifetime.
That said, if the 4B sounds interesting, check out my assembly HowTo.

## Unboxing

The CanaKit is contained in a cardboard box (about 2" H x 10" W x 6" D).
The lid of the box is nestled between a pair of cardboard rails,
which you can use to determine and adjust the box's orientation:
The tops of the rails are smooth; the bottoms have some rough patches.

The lid is extended by a sealing flap which covers the front of the box.
After cutting through the paper label at the bottom edge of this flap,
you should be able to pull the flap (and its side wings) free
and open up the top of the box.
Once you have the box open, you can inspect and inventory its contents.

The box contains several items that you should set aside for now.
These include an inline Micro-USB power switch, a USB SD card reader,
an HDMI cable, and assorted paper items.
The only items of interest for assembling the kit are three cardstock boxes.
The heaviest of these contains the Micro-USB power adapter;
put it aside for the last part of the assembly process.

There should be a small bag with a zip lock top,
probably taped to the box that contains the processor board.
This contains a pair of Aluminum heat sinks,
used to transfer heat from integrated circuits to the surrounding air.
These are squarish objects with sets of fins on the tops
and double-sided sticky tape on the bottoms.
Put this bag in a safe place for now; youll need it shortly.

Extract the plastic case components and processor board from their boxes.
The outer box should now be empty.

*Note:*
None of the following steps should require any force: easy does it!

## Inspection

Let's take a few moments now to play with these parts
and get familiar with their layout.
Curiosity aside, this knowledge will be useful as we continue.

### Processor Board

The bottom of the processor board mostly contains tiny components
and the undersides of soldered-in components.
However, it also contains the socket for the microSD card.
This is located at the center of one end of the card.
The lip on the microSD card that aids in gripping it for removal
should be facing down when you insert the card into the slot.

However, the top has a number of tactile features
that will be useful in identifying the relevant components.
The most obvious feature is a set of three squarish metal boxes,
located at one end of the board.
Hold the board so that the end with these metal boxes is facing you.

The box on the left contains a 100Base-T socket,
which can be used to connect to a Local Area Network
via a CAT-5 or CAT-6 cable.
The notch in the bottom center of the opening provides room
for the locking clip on the 8P8C (aka RJ45) connector.

Each of the two right-hand boxes contains a pair
of (flat, rectangular) USB Type A sockets.
These can be used to communicate with peripheral devices
such as keyboards, printers, mass storage, etc.
They can also be used to communicate with subsidiary computing devices,
such as cell phones.

Most of the long edge on your right will be occupied
by two rows of General Purpose Input Output (GPIO) pins.
These can be used to communicate with a wide range of devices,
power a fan, etc.
However, we won't be using any of these pins in this HowTo.

You should be able to identify several connectors,
spaced along the left edge and back of the board.
In order, from front to back, these are:

- 1/8" (3.5 mm) stereo audio output jack
- flexible printed circuit connector (camera)
- full-size HDMI socket (audio-video output)
- Micro-USB socket (input power)
- flexible printed circuit connector (display)

### Plastic Case

Pick up the plastic case,
putting the end with the three large holes to your left.
Pull the lid (top plate) off and examine the under side.
The lid has a set of rounded extrusions located in the four corners. 
These press into the inside corners of the case body.
On one end, the space between these extrusions is unobstructed;
this end of the lid will sit above the three large holes in the body.
The center of the lid has about a dozen small holes,
forming the outline of raspberry, topped by a pair of leaves.
This is surrounded by some extrusions which we can safely ignore.

Now, reach into the case and push down gently on the bottom,
separating it from the case body.
Then, put the body aside so that you can concentrate on the case bottom.
Note that it has a notch at the center of one end;
this provides access to the microSD card socket, as mentioned above.
Four rubber feet provide a bit of traction
and dozens of small holes allow air to enter the case for cooling.

There are also a couple of specially-made holes
that can be used to attach the case to an adjacent surface.
Each of these holes has a protruding ring around its bottom
and a raised area (with a conical depression) around its top.
If you can locate small enough flat-head screws or bolts,
they will fit into these depressions,
staying out of contact with the processor board.
Be very cautious if you try to use these holes, however,
lest your bolts press on (or worse, short out) the board's circuitry.

In the corners adjoining the slot for the microSD card,
locate a pair of small extrusions.
These will be used to bind the processor board
to this end of the case bottom.

Finally, examine the case body itself.
At one end, there is a raised area that covers the Ethernet and USB sockets.
The rest of the case body is spanned by a horizontal plate,
containing several holes.
These provide access to the GPIO pins, flexible printed circuit connectors,
and the tops of some integrated circuits (for cooling).

## Assembly

Position the processor board and the case bottom
such that the micro-SD socket (and corresponding notch) are away from you.
Slide the end of the board under the corner extrusions.
It goes in at a light angle, then snaps down to lie flat on the case bottom.
Place the middle of the case back over the bottom and press down
until it clicks into place.
Again, this should not require a lot of force.

### Heat Sinks

Now we get to the trickiest part of the assembly process:
mounting the two heat sinks on their respective chips.
It's clearly a bit difficult to put the heat sinks into place
through the holes in the case.
However, it's safer than putting them on first,
lest you get them slightly out of position
and prevent the case from snapping together.
In any case, it's important to do things right the first time:
peeling off and re-sticking the double-sided tape is tricky, at best.

Open the bag with the pair of heatsinks and identify the larger one.
Then, in the middle of the processor board, find a small, square hole.
At the bottom of this hole, you should feel a smooth metal square;
this is the lid of the Central Processing Unit (CPU).
Peel the slick plastic cover off the tape
on the bottom of the largest heat sink.
Center the heat sink in the hole, just over the CPU, and mash it down firmly. 

The second heat sink is mounted in much the same manner,
using a smaller square hole, located by the wall
that borders the Ethernet and USB connectors.
The raised area at the bottom of this hole is the Ethernet chip.
Remove the cover sheet from the tape on the heat sink
and mash the heat sink onto the chip, as centered as possible.

At this point, things get a lot easier again.
Snap the lid onto the case; if everything is lined up properly,
it should go on with little or no pressure.
Voila, you have now assembled your Raspberry Pi.

### USB Power

The RasPi 3 is powered by a USB power supply,
through a short switching cable.
Both of these deserve a bit of discussion.
The power cables use a Micro-USB connector,
which is very small and must be oriented properly in order to go in.
If this is your first experience with this connector, be patient;
once you get the knack, plugging it in will be only a minor nuisance.

The switching cable is pretty cute.
A small, toggling button controls the power:
Push it once for on and again for off.
Sighted users will notice a red LED that lights up when the switch is "on",
but the switch also has a (subtle) tactile indication.
When the switch is "on", the button sticks out a bit further.

### Final Assembly

Position the lid just above the body of the case.
Be sure that the "open" end of the lid is above the USB connectors.
Snap the lid onto the case; if everything is lined up properly,
it should go on with little or no pressure.

## Cabling, etc.

The RasPi is a rather tiny device,
but the amount of associated cabling and such can be a bit overwhelming.
Here's a typical rundown for a blind user:

- analog headphones, etc.
- USB power supply and cable
- USB power switch and cable
- USB keyboard

And, if you're working with a sighted associate,
you'll want to have something like the following items:

- USB mouse
- HDMI display, power supply, and cable

## Software

All you need to do now is grab a blind-accessible OS image,
put it on either a microSD card or a USB thumb drive,
and power up the system.

Although you could use the included 32 GB microSD card for this,
you may want to reserve that for emergencies,
since it contains a copy of NOOBS
(the RasPi's "New Out Of the Box Software").
The bottom of the RasPi case has a notch in the center of one end.
This allows access to the socket for the microSD card.
The lip on the microSD card that aids in gripping it for removal
should be facing down when you insert the card into the slot.

Alternatively, you may wish to put the system software on a USB thumb drive.
Unlike microSD cards, these typically have a mounting hole
that you can use to attach an identifying tag (e.g., with braille).
A thumb drive with a tag is much less likely to get misplaced
than a tiny, anonymous microSD drive.