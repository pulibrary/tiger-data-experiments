#!/usr/bin/env python3

from os import environ

import mfclient

if __name__ == '__main__':
    # create connection object
    connection = mfclient.MFConnection(
        host=environ['MF_HOST'],
        port=443, transport='https',
        domain=environ['MF_DOMAIN'],
        user=environ['MF_USERNAME'], password=environ['MF_PASSWORD'])
    try:
        # connect to mediaflux server
        connection.open()

        # run server.version service
        result = connection.execute('server.version')

        # print result xml
        print(result)

        # print Mediaflux server version
        print(result.value('version'))
    finally:
        connection.close()
