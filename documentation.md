# Cloud-1 Project Documentation
---
## 1. Prerequisites & Local Environment Setup
- Make sure you have `ansible` and `ansible-galaxy` installed on your machine

	This project relies on external modules to manage system users, SSH authorization, and firewall configurations. Install the required collections by running the following commands in your terminal:

	```bash
	ansible-galaxy collection install community.general

	ansible-galaxy collection install ansible.posix --force
	```

- Environment Variables Configuration
	The playbooks dynamically read configurations from a local environment file.

	In the project root directory, copy the provided example file to create your active environment configuration:
   ```bash
   cp .env_example .env
   ```
   Open the newly created `.env` file and define your target deployment username:
   ```ini
   target_deploy_user=your_custom_username
   ```

- Create an `inventory.yml` in the `ansible/` folder. Populate it with your cloud target IPs
	```
	all:
	  hosts:
	    cloud-1:
	      ansible_host: 10.12.2.6
	    cloud-2:
	      ansible_host: 10.12.2.7
	    cloud-3:
	      ansible_host: 10.12.2.8
	```
> **Execution Directory Tip:** Since the inventory file is located inside the `ansible/` folder, it is strongly recommended to execute all playbook commands from within this directory. If you choose to run commands from a different folder, you must explicitly append `-i [path/to/your/inventory.yml]` to your execution string, or override the default pathing inside an `ansible.cfg` file.

## 2. First Run on a Freshly Provisioned Server
Because a freshly provisioned cloud instance only has the provider's default administrative user, you must run the bootstrap playbook **once** to create your secure deployment user and authorize your local SSH keys.
`ansible-playbook playbooks/first_setup.yml -u [server-user] -k -K`
- Replace `[server-user]` with the default administration username provided by your cloud host (e.g., ubuntu, debian, root).
- `-k`: Prompts you for the default user's initial SSH password.
- `-K`: Prompts you for the root/sudo password so Ansible has permissions to create the new account.
