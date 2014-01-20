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

nconf = require('nconf');
nconf.argv();
nconf.defaults({'host': 'localhost', 'port': 4242, 'login': 'YOUR_USER_NAME', 'password': 'YOUR_PASSWORD', 'room': 'defaultRoom', 'spKey': 'spotify_appkey.key'});

Application = require('./Application.coffee');

main = () ->
	application = new Application()
	application.run()

main()