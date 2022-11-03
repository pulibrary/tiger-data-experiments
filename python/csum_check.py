import mfclient
import os
import posixpath
import zlib
import mf_connect



def asset_exists(connection, asset_path):
    '''
    Check if Mediaflux asset at the given path exists
    @param connection: Medaiflux server connection object
    @type connection: mfclient.MFConnection
    @param asset_path: asset path
    @type asset_path: str
    @return:
    @rtype: bool
    '''
    w = mfclient.XmlStringWriter('args')
    w.add("id", f'path={asset_path}')
    re: mfclient.XmlElement
    re = connection.execute('asset.exists', w.doc_text())
    return re.boolean_value('exists')


def get_file_checksum(file_path):
    '''
    Calculate CRC32 checksum for the specified file.
    @param file_path: file path
    @type file_path: str
    @return:
    @rtype: int
    '''
    with open(file_path, 'rb') as f:
        buffer_size = 8192
        crc = 0
        buf = f.read(buffer_size)
        while len(buf) > 0:
            crc = zlib.crc32(buf, crc)
            buf = f.read(buffer_size)
        return crc


def get_asset_checksum(connection, asset_path=None, asset_id=None):
    '''
    Retrieve the CRC32 checksum from asset meta data.
    @param connection: Medaiflux server connection object
    @type connection: mfclient.MFConnection
    @param asset_path: asset path
    @type asset_path: str
    @param asset_id: asset id
    @type asset_id: str
    @return:
    @rtype: int
    '''
    if asset_path is None and asset_id is None:
        raise ValueError('Asset path or id must be supplied!')
    w = mfclient.XmlStringWriter('args')
    w.add("id", asset_id if asset_id else f'path={asset_path}')
    re: mfclient.XmlElement
    re = connection.execute('asset.get', w.doc_text())
    crc = re.int_value("asset/content/csum[@base='10']")
    return crc


def get_asset_path(file_path, base_dir, base_asset_namespace):
    '''
    Resolve the corresponding asset path for the given file.
    @param file_path:
    @type file_path: str
    @param base_dir:
    @type base_dir: str
    @param base_asset_namespace:
    @type base_asset_namespace: str
    @return:
    @rtype: str
    '''
    file_path = os.path.normpath(file_path);
    rel_path = os.path.relpath(file_path, base_dir).replace(os.sep, '/')
    return posixpath.join(base_asset_namespace, rel_path).replace(os.sep, '/')


def get_file_path(asset_path, base_asset_namespace, base_dir):
    '''
    Resolve the corresponding files path for the given asset.
    @param asset_path:
    @type asset_path:
    @param base_asset_namespace:
    @type base_asset_namespace:
    @param base_dir:
    @type base_dir:
    @return:
    @rtype: str
    '''
    rel_path = posixpath.relpath(asset_path, base_asset_namespace).replace('/', os.sep)
    return os.path.join(base_dir, rel_path).replace('/', os.sep);


def check_upload(connection, src_directory, dst_asset_namespace):
    '''
    Compare files in local directory with assets in remote Mediaflux asset namespace.
    @param connection: Mediaflux server connection object.
    @type connection: mfclient.MFConnection
    @param src_directory: source (local) directory
    @type src_directory: str
    @param dst_asset_namespace: destination (Mediaflux) asset namespace (directory)
    @type dst_asset_namespace: str
    @return:
    @rtype:
    '''
    nb_missing = 0
    nb_mismatch = 0
    nb_match = 0
    nb_files = 0
    nb_assets = 0
    src_directory = os.path.normpath(src_directory)
    for subdir, dirs, files in os.walk(src_directory):
        for file in files:
            nb_files += 1
            file_path = os.path.join(subdir, file)
            asset_path = get_asset_path(file_path, src_directory, dst_asset_namespace)
            if not asset_exists(connection, asset_path):
                nb_missing += 1
                print(f"asset: '{asset_path}' does not exist.")
            else:
                nb_assets += 1
                file_checksum = get_file_checksum(file_path)
                asset_checksum = get_asset_checksum(connection, asset_path)
                if file_checksum != asset_checksum:
                    nb_mismatch += 1
                    print(
                        f"asset: '{asset_path}' (crc32={asset_checksum}) does not match file: '{file_path}' (crc32={file_checksum})")
                else:
                    nb_match += 1
                    print(f"asset: '{asset_path}' matches file: '{file_path}' (crc32={file_checksum})")

    print()
    print(f'total number of (local) files: {nb_files}')
    print(f'total number of (mediaflux) assets: {nb_assets}')
    print(f'number of files missing: {nb_missing}')
    print(f'number of files mismatch: {nb_mismatch}')
    print()


def check_download(connection, src_asset_namespace, dst_directory):
    '''
    Compare files in local directory with assets in remote Mediaflux asset namespace.
    @param connection: Mediaflux server connection object.
    @type connection: mfclient.MFConnection
    @param src_asset_namespace: the source (Mediaflux) asset namespace (directory).
    @type src_asset_namespace: str
    @param dst_directory: the destination (local) directory.
    @type dst_directory: str
    @return:
    @rtype:
    '''
    complete = False
    idx = 1
    size = 100  # page size
    nb_assets = 0
    nb_files = 0
    nb_missing = 0
    nb_mismatch = 0
    nb_match = 0
    while not complete:
        w = mfclient.XmlStringWriter('args')
        w.add('where', f"namespace>='{src_asset_namespace}'")
        w.add('action', 'get-meta')
        w.add('idx', idx)
        w.add('size', size)
        re: mfclient.XmlElement
        re = connection.execute('asset.query', w.doc_text())
        complete = re.boolean_value('cursor/total/@complete')
        idx += size
        aes = re.elements('asset')
        if aes:
            ae: mfclient.XmlElement
            for ae in aes:
                nb_assets += 1
                asset_path = ae.value('path')
                file_path = get_file_path(asset_path, src_asset_namespace, dst_directory)
                if not os.path.exists(file_path) or not os.path.isfile(file_path):
                    nb_missing += 1
                    print(f"file: '{file_path}' does not exist.")
                else:
                    nb_files += 1
                    asset_checksum = ae.int_value("content/csum[@base='10']")
                    file_checksum = get_file_checksum(file_path)
                    if file_checksum != asset_checksum:
                        nb_mismatch += 1
                        print(
                            f"asset: 'file: '{file_path}' (crc32={file_checksum}) does not match {asset_path}' (crc32={asset_checksum})")
                    else:
                        nb_match += 1
                        print(f"file: '{file_path}' matches asset: '{asset_path}' (crc32={file_checksum})")
    print()
    print(f'total number of (mediaflux) assets: {nb_assets}')
    print(f'total number of (local) files: {nb_files}')
    print(f'number of files missing: {nb_missing}')
    print(f'number of files mismatch: {nb_mismatch}')
    print()


if __name__ == '__main__':
    # create connection object (NOTE: You need to substitute with your server details and user credentials.)
    connection = mf_connect.connect()
    try:
        # connect to mediaflux server
        connection.open()

        # check upload
        check_upload(connection, '/tmp/acme', '/acme/')

        # check download
        check_download(connection, '/acme', '/tmp/acme')

    finally:
        connection.close()
