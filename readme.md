The Mega Drive kit for Blitz Basic is early in development, and is missing support for vital features like sprites, audio and controllers. What I've developed so far is likely to break if extreme care isn't taken (if for example a Blitz library that opens an Amiga library is used), and I may not be able to provide support - but it's here for you to tinker if you wish, and help developing the library would be appreciated.

Blitz Basic wasn't designed with the Mega Drive in mind, but the Mega Drive being a 68K platform means that Blitz Basic is certainly an option for developing on it (and in fact, it was used to develop the Mega Drive version of Super Skidmarks).

Included is the library, an example program (based on a BigEvilCorporation tutorial) and a tool for converting an Amiga Blitz Basic executable to a Mega Drive ROM.

Library currently uses library number 89, this may change.


Hello World test instructions:
- Open helloworld.bb in Blitz Basic 2 (AmiBlitz may work but is untested)
- Compile to a file simply called "HelloWorld"
- Run this command from the CLI - "Blitz2Sega HelloWorld HelloWorld.rom"
- Open HelloWorld.rom in a Mega Drive emulator, you should see the words "Hello World" displayed.


Special thanks to Acid Software - not simply for the amazing Blitz Basic compiler, but also for the Mega Drive version of Skidmarks which is an inspiration for this project.


If you'd like to support the development of this project, backing the Scorpion Engine patreon would be a major help!

Earok
https://www.patreon.com/scorpionengine
