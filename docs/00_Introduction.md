**Dj Yayo** is a modern jukebox that let you share music with everyone around you.

This project is composed of three different part.

## Project Organisation ##

### Server ###
This part handle the room and the track system. It provide a REST HTTP API that allow other applications to get information about room players or tracks.

### Web application ###
This is the GUI of the project. It's a web application that use the server REST API to access room information and allow user to search and vote music.

### Player ###
The player provide the link between a music provider (i.e. spotify) and the server.
The player is in charge of playing the music, search and retrieve songs using music provider's api (i.e. spotify API).