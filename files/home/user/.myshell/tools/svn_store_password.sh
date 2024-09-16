#!/bin/bash

svn_store_password(){
    patch_svn='''
    # patch_svn Start
    [global]
    store-passwords = yes
    store-plaintext-passwords = yes
    '''
    if ! [ -d ~/.subversion/servers ]; then
        mkdir -p ~/.subversion
        touch ~/.subversion/servers
    fi
    sed -i "/# patch_svn Start/Q" ~/.subversion/servers && echo "$patch_svn" >> ~/.subversion/servers
}
svn_store_password