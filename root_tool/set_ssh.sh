function set_ssh(){
    sed -i '/^PubkeyAcceptedAlgorithms/d;$aPubkeyAcceptedAlgorithms +ssh-rsa' /etc/ssh/sshd_config
    sed -i '/^PermitRootLogin/d;$aPermitRootLogin yes' /etc/ssh/sshd_config
    sed -i 's|#MaxAuthTries.*|MaxAuthTries 30|' /etc/ssh/sshd_config
    sed -i 's|MaxAuthTries.*|MaxAuthTries 30|' /etc/ssh/sshd_config
}

set_ssh