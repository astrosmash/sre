#!/usr/bin/python
# -*- coding: utf-8 -*-

import json
import os
import thread
import time
from socket import *
from pyparsing import nums, Combine, Optional, Regex, Suppress, Word


class Parser(object):

    def __init__(self):
        integer = Word(nums).setParseAction(lambda t: int(t[0]))  # The lambda expression defines a nameless function that takes a list of tokens and converts the first token to an int.
        incomingDate = Suppress(Optional('[')) + Combine(integer + '/'
                + integer + '/' + integer) + Combine(integer + ':'
                + integer) + Suppress(Optional(']'))
        incomingMessage = Regex('.*')
        self.__pattern = incomingDate + incomingMessage

    def parse(self, line):
        parsed = self.__pattern.parseString(line)
        time_tuple = time.strptime(parsed[0] + parsed[1], '%d/%m/%Y%H:%S')
        time_epoch = time.mktime(time_tuple)
        payload = {}
        payload['timestamp'] = int(time_epoch)
        payload['hostname'] = (getfqdn(clientaddr[0]))
        payload['container'] = os.uname()[1]
        payload['message'] = parsed[2]
        return json.dumps(payload, ensure_ascii=False, sort_keys=True)


def handler(clientsocket, clientaddr):
    parser = Parser()
    while 1:
        data = clientsocket.recv(buf)
        if not data:
            break
        else:
            fields = parser.parse(data)
            print fields
    clientsocket.close()


if __name__ == '__main__':

    host = ''
    port = 1234
    buf = 1024
    addr = (host, port)
    serversocket = socket(AF_INET, SOCK_STREAM)
    serversocket.bind(addr)
    serversocket.listen(2)

    while 1:
        (clientsocket, clientaddr) = serversocket.accept()
        thread.start_new_thread(handler, (clientsocket, clientaddr))
    serversocket.close()
