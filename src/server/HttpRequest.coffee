##
# Copyright 2012 Jerome Quere < contact@jeromequere.com >.
#
# This file is part of SpotifyDJ.
#
# SpotifyDJ is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpotifyDJ is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SpotifyDJ.If not, see <http://www.gnu.org/licenses/>.
##

class HttpRequest extends require('events').EventEmitter
	constructor: (@request, @response) ->
		@data = "";
		@request.on('data', @onData);
		@request.on('end', @onEnd);

	getUrl: () => @request.url

	getCookies: () =>
		cookies = {};
		if (@request.headers.cookie?)
			@request.headers.cookie.split(';').forEach (cookie) ->
				parts = cookie.split('=')
				cookies[ parts[0].trim() ] = ( parts[1] || '' ).trim();
		return cookies

	getParam: () => {}

	onData: (buffer) =>
		@data = @data.concat(buffer);

	onEnd: () =>
		if (@data != "")
			@data = JSON.parse(@data);
		else
			@data = null;
		@emit('requestComplete', this, @response);

	getData: () =>
		return @data

	@request
	@response
	@data;


module.exports = HttpRequest;