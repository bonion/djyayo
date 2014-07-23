	/room/:roomName/nextTrack

This endpoint allow you to play the next track on the queue. If a track is currently playing it will be stop first.

### Parameters ###
* **:roomName** *(required)* : The name of the room where you want to play the next song.

### Response ###
```json
"Success"
```

### Permissions ###
You must be an **admin** of the room to access this endpoint.