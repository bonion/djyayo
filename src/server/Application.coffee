##
#The MIT License (MIT)
#
# Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
##


express = require('express');
fn   = require("when/function");
http = require('http')

Config = require('./Config.coffee');
SessionManager = require('./SessionManager.coffee');
HttpErrors = require('./HttpErrors.coffee');
Logger = require('./Logger.coffee');
PlayerCommunicator = require('./PlayerCommunicator.coffee');
RoomManager = require('./RoomManager.coffee');
Testor = require('./Testor.coffee');
UserManager = require('./UserManager.coffee')
WebSocketCommunicator = require('./WebSocketCommunicator.coffee');

class Application

	constructor: () ->
		@users = {}
		@express = express();
		@httpServer = http.createServer(@express)
		@webSockCom = new WebSocketCommunicator(@httpServer)
		@playerCom = new PlayerCommunicator();
		@webSockCom.on('command', @onWebSocketCommand);
		@playerCom.on('joinRoom', @onPlayerJoinRoom);
		@sessionManager = new SessionManager();
		@buildRoutes();

	buildRoutes: () ->

		buildHandler = (handler) => (req, res) => @onHttpRequest(req, res, handler);
		@express.use (req, res, next) ->
			res.header("Access-Control-Allow-Origin", "*");
			res.header("Access-Control-Allow-Headers", "X-Requested-With");
			next()

		@express.get('/login', buildHandler(@onLoginRequest));
		@express.get('/rooms', buildHandler(@onRoomsRequest));
		@express.get("/room/:room", buildHandler(@onRoomRequest));
		@express.get("/room/:room/search", buildHandler(@onSearchRequest));
		@express.get("/room/:room/nextTrack", buildHandler(@onRoomNextTrackRequest));
		@express.get("/room/:room/deleteTrack", buildHandler(@onRoomDeleteTrackRequest));
		@express.get("/room/:room/queue", buildHandler(@onQueueRequest));
		@express.get("/room/:room/vote", buildHandler(@onVoteRequest));
		@express.get("/room/:room/unvote", buildHandler(@onUnvoteRequest));
		@express.get("/room/:room/create", buildHandler(@onRoomCreateRequest));
		@express.get("/me", buildHandler(@onMeRequest));

	onHttpRequest: (request, response, handler) =>
		promise = fn.call(handler, request, response);
		promise.then (data) -> response.json({code: 200, msg: "Success", data: data});
		promise.otherwise (error) ->
			code = if (error.code?) then error.code else 500;
			msg = if (error.msg?) then error.msg else "" + error;
			if (error.stack) then console.log(error.stack);
			response.json({code: code, msg: msg, data: null});

	getAndTestSession: (request, th = true) =>
		token = Testor(request.query.access_token, HttpErrors.mustBeLoggedIn()).isMD5().toString();
		session = @sessionManager.get(token);
		if (session == null && th == true)
			throw HttpErrors.mustBeLoggedIn();
		return session;

	onLoginRequest: (request, response) =>
		method = Testor(request.query.method, HttpErrors.badParams()).isIn(["facebook", "google"]).toString();
		token = Testor(request.query.token, HttpErrors.badParams()).isNotEmpty().toString();
		if (method == "facebook")
			promise = UserManager.loadFromFacebook(token);
		else
			promise = UserManager.loadFromGoogle(token);
		return promise.then (user) =>
			token = @sessionManager.create();
			@sessionManager.get(token).setUser(user);
			return {access_token:token};

	onMeRequest: (request, response) =>
		session = @getAndTestSession(request)
		return session.getUser().getData();

	onRoomsRequest: (request, response) =>
		return RoomManager.getList()

	onRoomRequest: (request, response) =>
		room = RoomManager.get(request.params.room);
		if (!room?)
			throw HttpErrors.invalidRoomName()
		data = room.getData();
		data.admin = room.isAdmin(session.getUser().getId());
		return data;

	onRoomCreateRequest: (request, response) =>
		session = @getAndTestSession(request)
		room = RoomManager.get(request.params.room);
		if (room?)
			throw HttpErrors.invalidRoomName()
		room = RoomManager.create(request.params.room);
		if (!room?)
			throw HttpErrors.invalidRoomName()
		room.addAdmin(session.getUser().getId());
		return @onRoomRequest(request, response);

	onUnvoteRequest: (request, response) =>
		session = @getAndTestSession(request)
		room = RoomManager.get(request.params.room)
		Testor(room, HttpErrors.invalidRoomName()).isNotNull();
		uri = Testor(request.query.uri, HttpErrors.badParams()).isNotEmpty().toString();
		room.unvote(session.getUser().getId(), uri);
		return @onRoomRequest(request, response)

	onVoteRequest: (request, response) =>
		session = @getAndTestSession(request)
		room = RoomManager.get(request.params.room)
		Testor(room, HttpErrors.invalidRoomName()).isNotNull();
		uri = Testor(request.query.uri, HttpErrors.badParams()).isNotEmpty().toString();
		return room.vote(session.getUser().getId(), uri).then () =>
			return @onRoomRequest(request, response)

	onSearchRequest: (request, response) =>
		room = RoomManager.get(request.params.room)
		Testor(room, HttpErrors.invalidRoomName()).isNotNull();
		query = Testor(request.query.query, HttpErrors.badParams()).isNotEmpty().toString();
		return room.search(query)

	onRoomNextTrackRequest: (request, response) =>
		session = @getAndTestSession(request)
		room = RoomManager.get(request.params.room)
		Testor(room, HttpErrors.invalidRoomName()).isNotNull();
		Testor(room.isAdmin(session.getUser().getId()), HttpErrors.permisionDenied()).isTrue();
		room.playNextTrack();
		return "Success"

	onRoomDeleteTrackRequest: (request, response) =>
		session = @getAndTestSession(request)
		room = RoomManager.get(request.params.room)
		Testor(room, HttpErrors.invalidRoomName()).isNotNull();
		Testor(room.isAdmin(session.getUser().getId()), HttpErrors.permisionDenied()).isTrue();
		uri = Testor(request.query.uri, HttpErrors.badParams()).isNotEmpty().toString();
		room.deleteTrack(uri);
		return "Success";

	onPlayerJoinRoom: (player, roomName) =>
		room = RoomManager.get(roomName);
		if (!room)
			return player.error("The room #{roomName} doesn't exist");
		room.addPlayer(player);

	onChangeRoomCommand: (client, command) =>
		room = RoomManager.get(command.getArgs().room);
		if (!room) then return;
		room.addClient(client);

	onWebSocketCommand: (client, command) =>
		if (command.getName() == "changeRoom")
			@onChangeRoomCommand(client, command);
	run : () ->
		@httpServer.listen(Config.getPort());

module.exports = Application;