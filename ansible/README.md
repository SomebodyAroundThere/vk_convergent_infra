Ansible usage:
1. Fill inventories/hosts.ini with real IPs.
2. Set vault password file ./vault.pass (local file containing vault password).
3. Encrypt group_vars/all/vault.yml with ansible-vault or edit it and run: ansible-vault encrypt group_vars/all/vault.yml
4. Run: ansible-playbook playbook.yml
