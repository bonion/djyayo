/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
 *
 * Permission is hereby granted, free  of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction,  including without limitation the rights
 * to use,  copy,  modify,  merge, publish,  distribute, sublicense, and/or sell
 * copies  of  the  Software,  and  to  permit  persons  to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The  above  copyright  notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED  "AS IS",  WITHOUT WARRANTY  OF ANY KIND, EXPRESS OR
 * IMPLIED,  INCLUDING BUT NOT LIMITED  TO THE  WARRANTIES  OF  MERCHANTABILITY,
 * FITNESS  FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR  ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT  OF  OR  IN  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef _SPDJ_COMMUNICATOR_H_
#define _SPDJ_COMMUNICATOR_H_

#include <vector>

#include "EventEmitter.h"
#include "Socket.h"

namespace SpDj
{
    class Communicator : public EventEmitter
    {
	enum State
	    {
		NONE,
		CONNECTING,
		CONNECTED
	    };

    public:
	Communicator();
	~Communicator();
	When::Promise<bool> start();

	bool send(const Command&);

    private:

	bool isCommandReady();
	std::string getLine();
	void onData(const std::vector<int8_t>&);
	void onConnect();
	void onEnd();

	void restart();
	void onTimeout();

	std::vector<int8_t> _buffer;
	Socket*	_socket;
	State	_state;
    };
}

#endif
