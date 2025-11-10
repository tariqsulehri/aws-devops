ssh -i /Users/tk-lpt-1088/Desktop/python-dev/DevOps/applications/devops/ansible/keys_files/web_server_key.pem \
    -o "ProxyCommand=ssh -i /Users/tk-lpt-1088/Desktop/python-dev/DevOps/applications/devops/ansible/keys_files/web_server_key.pem -W %h:%p ubuntu@51.20.104.250" \
    ubuntu@10.0.2.88