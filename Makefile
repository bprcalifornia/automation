# Define build variables
ssh_host = bpr
dest_dir = ~/automation

# Standard build task
build: deploy

# Deploy task to send the contents of the directory to the remote server recursively
deploy:
	rsync -rlvuzh -e ssh --delete \
		--exclude "node_modules/" \
		--exclude "vendor/" \
		--exclude=".svn/" \
		--exclude=".git/" \
		--exclude=".vscode/" \
	. ${ssh_host}:${dest_dir};