### Distributions

#### What distribution sizes are available?

Initially, our plan was to have only one Perkify distribution.
After all, we reasoned, storage is pretty much a non-issue.
And, in fact, we currently have only one "box" up on Vagrant Cloud.

However, even though storage may be a non-issue,
the time taken to download the "box" may not be.
So, we are now planning to create and upload multiple distributions,
in order to handle a range of use cases and user preferences.
For example:

- The Perkify_Small distribution will mostly add a11y-related packages.
  It should download rather quickly (about as fast as Ubuntu).

- The Perkify_Medium distribution will add packages
  of general utility and interest.
  It will take somewhat longer to download.

- The Perkify_Large distribution will add every plausible package.
  It will take a *lot* longer to download.

- The Perkify_Work distribution will add packages we're currently working on.
  Its size (and download time) will thus be somewhat variable.

#### What distribution types are available?

At the moment, the only distribution type we support
is a Vagrant "box", based on VirtualBox and Ubuntu.
We're willing to consider supporting other distribution types,
but our development bandwidth is quite limited.
So, feel free to pitch in...
