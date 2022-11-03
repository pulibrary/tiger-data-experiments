import mfclient
import config_connect as cc

def connect():

    cxn = mfclient.MFConnection(host=cc.mfhost, port=cc.mfport, transport=cc.transport,domain=cc.connect_domain,user=cc.connect_user,password=cc.connect_password,recv_timeout=60)
    # cxn.open(domain=cc.connect_domain,user=cc.connect_user,password=cc.connect_password)
    cxn.open()
    return cxn
