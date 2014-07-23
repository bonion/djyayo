	/room/:roomName/delAdmin?userID=USERID

This endpoint allow you to remove an admin from the room. You CAN'T revoke yourself as a room admin.

### Parameters ###
* **:roomName** *(required)* : The name of the room to which you want to remove an admin.
* **userId** *(required)*: The id of the user you want to revoke as admin.

### Response ###
The response is the same as [room users](room_users)

### Permissions ###
You must be an **admin** of the room to access this endpoint.