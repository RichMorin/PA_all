### Accessibility

#### What are you doing to make Perkify blind-accessible?

We started by selecting a number of interesting, text-based packages.
These can be used via [HTTP]{ext_wp|Hypertext_Transfer_Protocol},
[SSH]{ext_wp|Secure_Shell}, and even [X11]{ext_wp|X_Window_System}
via the host computer's screen reader(s).
We are now working on bringing up flexible and solid audio support,
using [ALSA]{ext_wp|Advanced_Linux_Sound_Architecture},
[JACK]{ext_wp|JACK_Audio_Connection_Kit},
[PulseAudio]{ext_wp|PulseAudio}, and some ancillary packages.

Once this is in place, we'll work on configuring various assistive packages
(e.g., music players, screen readers) to use it.
A lot of this should Just Work, but there will certainly be some exceptions.
