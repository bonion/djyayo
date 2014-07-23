	/room/:roomName/deleteTrack?uri=TRACKURI

This endpoint allow you to remove tracks from the queue.

### Parameters ###
* **:roomName** *(required)* : The name of the room where you want to remove the track.
* **uri** *(required)* : The uri of the track you want to remove.

### Response ###
```json
"Success"
```

### Permissions ###
You must be an **admin** of the room to access this endpoint.