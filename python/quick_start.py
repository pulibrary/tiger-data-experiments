import mfclient
import mf_connect

if __name__ == '__main__':
    # create connection object (NOTE: You need to substitute with your server details.)
    connection = mf_connect.connect()
    try:
        # connect to mediaflux server
        connection.open()

        # run server.version service
        result = connection.execute('server.version')

        # print result xml
        print(result)

        # print server version
        print(result.value('version'))
    finally:
        connection.close()
