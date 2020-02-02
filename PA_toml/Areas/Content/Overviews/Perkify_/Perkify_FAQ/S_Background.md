### Background

#### Why base Perkify on Linux?

As well as being the most popular open source operating system,
Linux is the primary target platform for open source software developers.
Even if a package was developed on another system,
it's likely to have a "port" that runs on Linux.
Better yet, tens of thousands of packages
can be downloaded from archive sites and installed automagically.
Given that Perkify is an open source distribution,
Linux is the obvious starting point.

#### Why base Perkify on the APT?

Although every Linux distribution uses (roughly) the same kernel,
each one includes a particular set of commands, libraries, etc.
Various families of Linux distributions share common characteristics,
including package management archives, practices, and tooling.

Getting reliable numbers is pretty much impossible,
but it's clear that the Debian family is the most popular.
It includes Mint, Raspbian, Ubuntu, WSL, and many other distributions.
With that popularity comes a wealth of open source software,
available via Debian's
Advanced Package Toolkit ([APT]{ext_wp|APT_(software)}).

The APT is a very convenient and extremely reliable set of tools,
supported by a worldwide network of archive sites, developers, etc.
It greatly simplifies the task of creating Perkify.
For example, we only have install about 200 packages explicitly;
the APT brings in all of the others they depend on or recommend.

#### Why base Perkify on Ubuntu?

Unlike Debian, Ubuntu releases new versions every six months.
So, the software in their distributions tends to be reasonably current.
Nonetheless, it has a very good reputation for reliability.
And, because Ubuntu is targeted at a broad range of users,
one need not be a Linux expert to make use of it.

#### What does Perkify add, in general?

Many experienced Linux users regularly install open source packages.
However, adding, configuring, and removing packages can be a hassle.
More seriously, it can destabilize the host operating system.
Because Perkify runs entirely inside a virtual machine,
it is much less likely to have troublesome interactions.

Given that Perkify adds several thousand packages to Ubuntu,
these interactions require (and receive) a certain amount of care.
Also, as Perkify becomes more mature as a distribution,
its components will become better integrated with each other.
So, it should become ever more convenient and powerful as time goes on.

#### What makes Perkify "blind-friendly"?

We started by selecting a number of interesting, text-based packages.
Many of these have been around for years,
but may not be familiar to most modern users.
These can typically be used via the host computer's screen reader(s),
using [HTTP]{ext_wp|Hypertext_Transfer_Protocol},
[SSH]{ext_wp|Secure_Shell}, or (sometimes) [X11]{ext_wp|X_Window_System}.

We are now working on bringing up flexible and solid audio support,
using [ALSA]{ext_wp|Advanced_Linux_Sound_Architecture},
[JACK]{ext_wp|JACK_Audio_Connection_Kit},
[PulseAudio]{ext_wp|PulseAudio}, and some ancillary packages.
Once this is in place, we'll work on configuring various assistive packages
(e.g., music players, screen readers) to use it.
