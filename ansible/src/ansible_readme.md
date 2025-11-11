

Roles:
---------
ansible-galaxy init mysql

using roles:
--------------
my-playbook-> playbook.yml
 - name: Install and configure MySql
   hosts: db-server

   roles:
       - mysql

To easy identify roles you need to use could be add in:
my-playbook
           ---> playbook.yml (file)
           ---> roles (folder)
                ---> mysql (folder)
                       - README.md (file)
                       - templates (folder) 
                       - tasks     (folder)
                       - handlers  (folder)
                       - vars      (folder)
                       - defaults  (folder)
                       - meta      (folder)

Configure Roles
-------------------
You can also move roles to a common directory:  /etc/ansible/roles
no you need to configure roles path: 
-  roles_path = /etc/ansible/roles

- Ansible find roles in default directory if it will not find any role in your working directory.
- Then you can use roles in any playbook without copy them to the playbook folder.

Find roles from Galaxy
-----------------------
open galaxy find mysql

command: 
 - ansible-galaxy search mysql
 - ansible-galaxy list
 - ansible-config dump | grep ROLES
 - ansible-galaxy install geerlingguy.mysql.  -> it will copy role to a ansible default roles directory /etc/ansible/roles/geerlingguy.mysql
 - ansible-galaxy install geerlingguy.mysql -p ./roles

 - Now you can use roles in your PLAYBOOK 
   roles:
     - geerlingguy.mysql


COLLECTIONS:
---------------
- ansible-galaxy collection install network.cisco
- ansible-galaxy collection install amazon.aws
  ---
  -  hosts localhost
     collections:
        - amazon.aws

     tasks:

       - name: Create an S3 bucket
         aws_s3_bucket:
           name:  my-bucket
           region: us-east-1    


requirements.yml
-----------------
----
collections:
   - name: amazon.aws
     version: "1.5.0"

   - name: community.mysql
     src:  https://github.com/ansible-collection/community.mysql   
     version: "1.3.0"       