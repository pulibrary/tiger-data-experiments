# Demo how to connect to MediaFlux, create an asset, getting asset metadataa,
# and changing asset metadata.
#
# This file is a combination of the "main" program in the README.md at
# https://gitlab.unimelb.edu.au/resplat-mediaflux/python-mfclient and the
# code in https://gitlab.unimelb.edu.au/resplat-mediaflux/python-mfclient/blob/master/examples/manage_asset_metadata.py
#
# The core functionality is provided by mfclient.py which is an exact copy of the file
# at https://gitlab.unimelb.edu.au/resplat-mediaflux/python-mfclient/-/blob/master/src/mfclient.py
#
# To run this:
#   git clone https://github.com/pulibrary/tiger-data.git
#   cd tiger-data/demos
#   # update the MF_HOST, MF_DOMAIN, MF_USER, and MF_PASSWORD values in demo.py
#   python3 demo.py
#
import datetime
import re
import mfclient

MF_PORT=443
MF_TRANSPORT='https'
MF_HOST='...'
MF_DOMAIN='...'
MF_USER='...'
MF_PASSWORD='...'

def create_asset(connection, name, namespace, note):
    """ Create an asset with specified name in the given namespace.

    :param connection: Mediaflux server connection object
    :type connection: mfclient.MFConnection
    :param name: Name of the asset
    :type name: str
    :param namespace: Destination asset namespace
    :type namespace: str
    :param note: Note for the asset
    :type note: str
    :return: id of the asset
    :rtype: int
    """
    # compose service arguments
    w = mfclient.XmlStringWriter('args')
    w.add('namespace', namespace, attributes={'create': True})  # the destination namespace where the asset is created
    w.add('name', name)
    w.push('meta')
    w.push('mf-name')
    w.add('name', name)
    w.pop()
    w.push('mf-note')
    w.add('note', note)
    w.pop()
    w.pop()

    # run asset.create service
    result = connection.execute('asset.create', w.doc_text())

    # return asset id
    asset_id = result.int_value('id')
    return asset_id


def get_asset_metadata(connection, asset_id):
    """ Gets asset metadata.

    :param connection: Mediaflux server connection object
    :type connection: mfclient.MFConnection
    :param asset_id: Asset id
    :type asset_id: int or str
    :return: asset metadata XmlElement object
    :rtype: mfclient.XmlElement
    """
    # compose service arguments
    w = mfclient.XmlStringWriter('args')
    w.add('id', asset_id)

    # run asset.get service
    result = connection.execute('asset.get', w.doc_text())

    asset_metadata = result.element('asset')
    return asset_metadata


def set_asset_metadata(connection, asset_id, new_name, new_note):
    """ Sets asset metadata

    :param connection: Mediaflux server connection object
    :param asset_id: Asset id
    :type asset_id: int or str
    :param new_name: New name for the asset
    :type new_name: str
    :param new_note:  New note for the asset
    :type new_note: str
    :return:
    """
    # compose service arguments
    w = mfclient.XmlStringWriter('args')
    w.add('id', asset_id)
    w.add('name', new_name)
    w.push('meta')
    w.push('mf-name')
    w.add('name', new_name)
    w.pop()
    w.push('mf-note')
    w.add('note', new_note)
    w.pop()
    w.pop()

    # run asset.set service
    result = connection.execute('asset.set', w.doc_text())


if __name__ == '__main__':
    # create connection object
    connection = mfclient.MFConnection(host=MF_HOST, port=MF_PORT, transport=MF_TRANSPORT, domain=MF_DOMAIN,
                                       user=MF_USER, password=MF_PASSWORD)
    try:
        # connect to mediaflux server
        connection.open()

        # run server.version service
        result = connection.execute('server.version')

        # print result xml
        print("== MediaFlux version information XML == ")
        print(result)

        # print Mediaflux server version
        print("== MediaFlux version number ==")
        print(result.value('version'))

        # Create a new asset in the "/acme" collection
        print("== Create asset ==")
        timestamp = re.sub(':','-',str(datetime.datetime.now()))
        new_asset_name = "hector-via-python-%s" % timestamp
        asset_id = create_asset(connection, new_asset_name, '/acme', 'this is a note')
        print(asset_id)

        # Get asset metadata
        print("== Asset metadata for %s ==" % asset_id)
        asset_metadata = get_asset_metadata(connection, asset_id)
        print(asset_metadata)

        # Change the metadata
        print("== Change asset metadata for %s ==" % asset_id)
        updated_asset_name = new_asset_name + " updated"
        result = set_asset_metadata(connection, asset_id, updated_asset_name, 'this is an updated note')
        print(result)

        # Get updated asset metadata
        print("== Asset metadata for % s ==" % asset_id)
        asset_metadata = get_asset_metadata(connection, asset_id)
        print(asset_metadata)

    finally:
        connection.close()


