# Raspberry Pi 4 B CanaKit Assembly

*Note:*
As an [AmazonSmile](https://smile.amazon.com) affiliate,
I will earn a commission on any products
purchased by following links from this page.
My commission does not affect the price you pay for the product.
It does, however, enable me to continue my work of bringing
affordable computers, accessible to the blind, to everyone everywhere.

Would you like to have a blind-accessible Linux system,
based on the [Raspberry Pi 4 CanaKit](
https://www.amazon.com/CanaKit-Raspberry-4GB-Starter-Kit/dp/B07V5JTMV9?tag=stormdragon29-20),
but haven’t dared to build one yourself?
Follow this HowTo and you won't get lost.

*Note:*
Much of this material is also covered in my YouTube video,
[Raspberry Pi 4 Unboxing](https://www.youtube.com/watch?v=_SjjsTvJ7Qw).

## Selection

If you haven't already made your selection, this might be a good time
to consider your options.
If you want a system with a longer battery lifetime,
faster and more powerful system, a Raspberry Pi 3 B+ might be a good choice.
Note, however, that the 3B+ has less processing power, limited RAM (1 GB),
and no fan (to give you an audible indication that the system is powered up).
That said, if the 3B+ sounds interesting, check out my assembly HowTo.

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
These include:

- a cooling fan
- a USB adaptor for SD cards 
- an inline USB-C power switch
- an HDMI to micro HDMI cable
- assorted paper items

Locate the three cardstock boxes that contain the major components.
The heaviest of these contains the USB-C power adapter;
put this aside for the last part of the assembly process.

There should be a small bag with a zip lock top,
probably taped to the box that contains the processor board.
This contains a set of three Aluminum heat sinks,
used to transfer heat from integrated circuits to the surrounding air.
These are squarish objects with sets of fins on the tops
and double-sided sticky tape on the bottoms.
Put this bag in a safe place for now; you'll need it shortly.

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

The box on the right contains a 1000Base-T socket,
which can be used to connect to a Local Area Network via a CAT-6 cable.
The notch in the bottom center of the opening provides room
for the locking clip on the 8P8C (aka RJ45) connector.

Each of the other two boxes contains a pair
of (flat, rectangular) USB Type A sockets.
These can be used to communicate with a variety of peripheral devices.
However, the connectors in the left-hand box are attached to USB 2.0,
so you should use them for low-speed devices such as keyboards and printers.
That way, the USB 3.0 connectors (in the center box) will be available
for use with USB flash drives, subsidiary computing devices, etc.

Most of the long edge on your right will be occupied
by two rows of General Purpose Input Output (GPIO) pins.
These can be used to communicate with a wide range of devices.
However, aside from powering the fan,
we won't be using any of these pins in this HowTo.

You should be able to identify several connectors,
spaced along the left edge and back of the board.
In order, from front to back, these are:

- 1/8" (3.5 mm) stereo audio output jack
- flexible printed circuit connector (camera)
- two micro HDMI sockets (audio-video output)
- USB-C socket (input power)
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
forming the outline of a raspberry, topped by a pair of leaves.
This is surrounded by some extrusions which will hold the fan in place.

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
The rest of the body is empty, allowing easy acccess to the GPIO pins,
flexible printed circuit connectors,
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
mounting the three heat sinks on their respective chips.
Fortunately, the open design of the RasPi 4 case makes this process easier
than it is for the RasPi 3 B+.
Still, it's important to do things right the first time:
peeling off and re-sticking the double-sided tape is tricky, at best.

Open the zip-lock bag containing the heatsinks and identify each one.
The largest one (about 1/2" square) is used on the CPU (processor).
The middle one (about 1/2" x 3/8") is used on the RAM (memory).
Finally, the smallest one is used on the USB 3.0 controller. 

Just to the left of the far end of the GPIO pins,
locate a short, rectangular metal case with square corners (about 1/2" x 3/8").
This is the WiFi/Bluetooth module.
Adjoining it, locate a short metal case with rounded corners (about 1/2" square).
This is the lid of the Central Processing Unit (CPU).
Peel the slick plastic cover off the tape
on the bottom of the largest heat sink.
Center and orient the heat sink on the CPU and mash it down firmly. 

The RAM chip is located right next to the CPU chip, a bit closer to you.
The top of this chip is flat and it won't stick up as high as the CPU lid.
Also, the right end of the camera connector nearly touches the RAM chip.
Peel the plastic cover off the next-smallest (rectangular) heat sink.
Orient the sink to match the chip and mash it down firmly. 

The USB 3.0 controller chip is quite small (about 1/4" square).
It is located in line with the space
between the RAM chip and the camera connector
and sits (logically enough very close to the USB 3.0 sockets.
Peel the plastic cover off the smallest heat sink.
Center and orient the sink, then mash it down firmly. 

Now that the heat sinks are in place,
locate the case body and snap it onto the case bottom.
Things are finally starting to come together!

### Cooling Fan

Locate the cooling fan and the lid of the case.
The fan body is about 1" square and 1/4" thick.
The motor is a circular disk, about 1/2" in diameter.
It is attached to the outside of the fan body by three short rails.
You can feel (and spin) the fan rotor on the other side of the fan. 
A pair of power leads emerge from the side of the fan, near one corner.
Each lead ends with a female connector, suitable for use on a GPIO pin.

Place the lid on its back, with the "open" (extrusion-free) end facing you.
On the inside of the lid, surrounding the raspberry-shaped holes,
there should be four flat extrusions and four extruded pins.
Position the fan with the motor on top (and the rotor below)
and the power leads coming out of the back-left corner.
Slide the fan between the flat extrusions and onto the extruded pins.
Once again, this should require very little force.

The fan will be powered by pins 4 and 6 on the GPIO bus.
Pin 4 supplies 5 VDC; pin 6 supplies a ground (return path) connection.
So, the first thing we need to do is find the relevant pins.
Once again, place the RasPi so that the USB sockets are facing you
and the GPIO pins are running along the right hand edge.
The left hand row contains the odd-numbered pins, with pin 1 at the top.
The right hand row contains the even-numbered pins, with pin 2 at the top.
Since we want pins 4 and 6, we need to use the 2nd and 3rd pins
from the top of the right hand row.

Unfortunately, there's a small complication.
Because the fan cares about the polarity of the voltage it receives,
We need to connect the red lead to pin 4 and the black lead to pin 6. 
If you have a sighted assistant on hand,
this might be a good time to ask them for help.

If not, just slide one connector onto pin 4 and the other onto pin 6. 
Don't worry; if you have things backward, nothing will burn up.
However, the fan won't spin up and you'll just have to reverse the leads.

### USB Power

The RasPi 4 is powered by a USB-C power supply,
through a short switching cable.
Both of these deserve a bit of discussion.
Unlike connectors used in earlier versions of USB,
the USB-C connector is rotationally symmetrical.
So, you don't have to worry about getting it in the right orientation.

The switching cable is also pretty cute.
A small, toggling button controls the power:
Push it once for on and again for off.
Sighted users will notice a red LED that lights up when the switch is "on",
but the switch also has a (subtle) tactile indication.
When the switch is "on", the button sticks out a bit further.
Also, once the fan is working, you can use its hum as an indication.

Get out the USB power supply and plug it into a powered outlet.
Next, plug the end of its cable into the socket on the end of the power switch.
Then, plug the cable from the power switch into the RasPi's USB-C socket.
Try clicking the switch; if the fan comes on, it's wired up correctly.
Otherwise, swap the fan leads (still on GPIO pins 4 and 6) and try again.

### Final Assembly

Position the lid just above the body of the case.
Be sure that the "open" end of the lid is above the USB connectors
and that the fan's power leads aren't sticking out from the case.
Snap the lid onto the case; if everything is lined up properly,
it should go on with little or no pressure.

## Cabling, etc.

The RasPi is a rather tiny device,
but the amount of associated cabling and such can be a bit overwhelming.
Here's a typical rundown for a blind user:

- analog headphones, etc.
- USB-C power supply and cable
- USB-C power switch and cable
- USB keyboard

And, if you're working with a sighted associate,
you'll probably want to have the following items:

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