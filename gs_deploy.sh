sudo useradd -m gs_deploy
sudo mkdir -p /home/gs_deploy/.ssh
sudo touch /home/gs_deploy/.ssh/authorized_keys
my_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCQubMJjNGRWnlD1eFyEyWKM/+FNJulNTd6IXe3HSTIs09twtw2+5OLwumr6nsPDwTRq1THTAxApArARTDs5r5f+aVvdgCXHXxB3djH7zKCcjvmFumIYOgdo6cKBLTPwIPw2UVIAJQDEybhL/49dI/DO5AaPn2v7DSlzwGFm8ywIMhprl2CvL5oZhunktNLvmpCb2vx7PHmnkBB5PvtdT1Fk9dQXklMDWE6wrEYnqnIKBIAJvwOIEb+f1jSkjQsHZVdGC8f5BYsBBCz/+XFeg6Pk/2ZwjQgavLrDLVihztQUPEogRUd62k9JVel/otNIqpA5KKBukONlB1oTobLkh//QHynh2mCXDmg0U0NO0a+8370QXuZ08oAxG9TQWY4gTIn4D0oAdBVNsvXsqhsRJfko9pNBCOQX6HMalmH+I/+CoLMd2AhELG6zIM8133xiBF3wj0+f9sfLlzwIih7thS5fUA5NEoeMMUsThNcjAqJdP1//WbFIg0LrGORn3RzVk= hotgame_gs_deploy"
sudo grep -q "$my_pubkey"  /home/gs_deploy/.ssh/authorized_keys || sudo echo "$my_pubkey" >>  /home/gs_deploy/.ssh/authorized_keys

sudo chown -R gs_deploy:gs_deploy /home/gs_deploy/.ssh
sudo chmod 755 /home/gs_deploy/.ssh
sudo chmod 644 /home/gs_deploy/.ssh/authorized_keys