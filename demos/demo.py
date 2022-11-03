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
# Examples:
#   python3 demo.py create
#   python3 demo.py get 1234
#   python3 demo.py update 1234
#
import datetime
import re
import mfclient
import os
import sys

MF_PORT=443
MF_TRANSPORT='https'
MF_HOST=os.environ.get('MF_HOST', "your-host")
MF_DOMAIN=os.environ.get('MF_DOMAIN', "your-domain")
MF_USER=os.environ.get('MF_USER', "your-user")
MF_PASSWORD=os.environ.get('MF_PASSWORD', "your-password")

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

    action = "help" if len(sys.argv) == 1 else sys.argv[1]
    asset_id = 0 if len(sys.argv) < 3 else sys.argv[2]

    # create connection object
    connection = mfclient.MFConnection(host=MF_HOST, port=MF_PORT, transport=MF_TRANSPORT, domain=MF_DOMAIN,
                                       user=MF_USER, password=MF_PASSWORD)
    try:
        # connect to mediaflux server
        print("Connecting to " + MF_HOST + " domain " + MF_DOMAIN + " as user " + MF_USER)
        connection.open()

        if action == "mf-version":
            result = connection.execute('server.version')
            print("== MediaFlux version information == ")
            print(result) # full XML
            print(result.value('version')) #version number
        elif action == "create":
            # Create a new asset in the "/acme" collection
            print("== Create asset ==")
            timestamp = re.sub(':','-',str(datetime.datetime.now()))
            new_asset_name = "hector-via-python-%s" % timestamp
            asset_id = create_asset(connection, new_asset_name, '/acme', 'this is a note')
            print(asset_id)
        elif action == "get":
            # Get asset metadata
            print("== Asset metadata for %s ==" % asset_id)
            asset_metadata = get_asset_metadata(connection, asset_id)
            print(asset_metadata)
            print(asset_metadata.value('name'))
        elif action == "update":
            # Change the metadata
            print("== Change asset metadata for %s ==" % asset_id)
            asset_metadata = get_asset_metadata(connection, asset_id)
            asset_name = asset_metadata.value('name')
            timestamp = re.sub(':','-',str(datetime.datetime.now()))
            result = set_asset_metadata(connection, asset_id, asset_name, 'this is an updated note ' + timestamp)
            print(asset_name)
        else:
            print("syntax:")
            print("    demo.py action [id]")
            print("")
            print("Valid actions: ")
            print("    mf-version")
            print("    create")
            print("    get")
            print("    update")
            print("")
            print("id represents an existing valid asset id in MediaFlux and it's required for get and update")
    finally:
        connection.close()


