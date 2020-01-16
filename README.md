Bach docker-compose projects manager
====================================

Author: Manlio García <info@manliogarcia.es>

This project aim to ease the deployment of docker-compose project
instances.

It does so by relying on docker image sources and docker-compose project
templates.

These utilities expect certain file structure to function, and usually require
root permissions to perform well.

Usage
-----

Just clone the project and it's dependencies:

`# git clone --recurse-submodules <git_clone_url> "/usr/local/lib/bach"`

Now add “/usr/local/lib/bach/bin” to your path.

`# export PATH="$PATH:/usr/local/lib/bach/bin"`

Make this permanent adding the command to your bashrc.

`# echo 'export PATH="$PATH:/usr/local/lib/bach/bin"' >>~/.bashrc`

You may also run `install_autocompletion.sh` to link bach autocompletion
scripts:

`# /etc/bach/install_autocompletion.sh`

Available commands
------------------

### bach [-h] [ARGS]

This command allows to create, manage and destroy docker-compose projects who
follow a strict convention in their structure. To learn how to use it, invoke
it with the “-h” flag as the first argument.

All possible actions may be invoked this way to get extra information about
them. I.E: you may call `bach -h generate <project_name>` to see a list of
possible arguments and their default values.

Relevant files and folders
--------------------------

### /etc/bach/config

This file contains a simple key-value dictionary, which holds the project
config values. You may have config files in the following locations:

* /etc/bach/config
* /etc/bach.conf
* ~/.bach/config
* ~/.bach.conf

Their contents will take precedence over the default values in that order.

If for some reason all of these files are missing, the scripts will resort to
default values.

Beware that some actions require having permissions over the files, specially
the backup script. This is not always guaranteed to be the case, I.E: for
volumes mounted in folders managed by docker.

### /etc/bach/image_sources/

Configurable with "IMAGE_SOURCES_FOLDER" option.

The project expect this folder to contain the sources for docker images. They
should be git projects, and the name of the folders shouls be the expected name
for the image. E.G: “/etc/docker-compose/image_sources/odoo11-atlantux”

### /etc/bach/compose_templates/

Configurable with "PROJECT_TEMPLATES_FOLDER" option.

The project will look here for templates of different docker-compose projects.
They should be git projects, and the name of each folder should be the name of
the service the project provides. E.G:
“/etc/docker-compose/compose_projects/odoo11”

### /srv/bach/<project_name>.d/<instance_name>/

Configurable with "INSTANCES_FOLDER" option.

Once created, a service instance should be stored in a structured way for other
tools to be aware of them. This folder will probably also contain a “data”
folder for the project persistent files and other instance files.

### /srv/bach_backups/<project_name>.d/<instance_name>/

Configurable with "BACKUP_FOLDER" option.

Backups generated with this tool will be here by default.
Once created, a service instance should be stored in a structured way for other
tools to be aware of them. This folder will probably also contain a “data”
folder for the project persistent files.

