
# BASH UTILS

*A random collection of scripts I have written over the years*

## Installation

Simply clone this repository or download the scripts you need from this repository's 
[releases](https://github.com/theCalcaholic/bash-utils/releases).

Don't forget to set executable permissions (`chmod +x`). :)

If you cloned it, you can add the following line to your ~/.bashrc:

```sh
. /path/to/cloned/repo/bash_aliases
. /path/to/cloned/repo/bash_aliases_auto
```

That will give you bash aliases for all the scripts in the repo.

## Scripts

- [anonymize-columns.sh](#anonymize-columnssh)
- [apt-install-temp.sh](#apt-install-tempsh)
- [bundle-script.sh](#bundle-scriptsh)
- [check-cert.sh](#check-certsh)
- [collect-bucket-permissions.sh](#collect-bucket-permissionssh)
- [collect-service-account-keys.sh](#collect-service-account-keyssh)
- [delete-bridge.sh](#delete-bridgesh)
- [du-tool.sh](#du-toolsh)
- [dyndns-update.sh](#dyndns-updatesh)
- [exec-on-change.sh](#exec-on-changesh)
- [fp-nvim-launcher.sh](#fp-nvim-launchersh)
- [gcp-list-projects-in-folder.sh](#gcp-list-projects-in-foldersh)
- [gcp-update-project-ssh-key-in-folder.sh](#gcp-update-project-ssh-key-in-foldersh)
- [gcp-update-project-ssh-key.sh](#gcp-update-project-ssh-keysh)
- [generate-bash-aliases.sh](#generate-bash-aliasessh)
- [generate-readme.sh](#generate-readmesh)
- [git-replace-author.sh](#git-replace-authorsh)
- [gs-touch.sh](#gs-touchsh)
- [iperf-log.sh](#iperf-logsh)
- [keepass-mounter.sh](#keepass-mountersh)
- [keepassxc-open-all-urls.sh](#keepassxc-open-all-urlssh)
- [lower-vpn-priority.sh](#lower-vpn-prioritysh)
- [prime-render-offload.sh](#prime-render-offloadsh)
- [reload_touchpad_driver_lenovo.sh](#reload_touchpad_driver_lenovosh)
- [setup-secure-dump.sh](#setup-secure-dumpsh)
- [show-gcs-bucket-modification-times.sh](#show-gcs-bucket-modification-timessh)
- [start-when-available.sh](#start-when-availablesh)
- [toggle-ssh-jumpserver.sh](#toggle-ssh-jumpserversh)
- [treediff.sh](#treediffsh)
- [virtual-mic.sh](#virtual-micsh)
- [whats-my-ip.sh](#whats-my-ipsh)
---
### anonymize-columns.sh

```yaml
Replaces specific columns in a csv table with generic data in the same format
by mapping '0-9' -> '0', 'a-z' -> 'a' and 'A-Z' -> 'A'

USAGE:
  anonymize-columns [OPTIONS] columns file
columns:
  A comma separated list of column ids to anonymize
  file:
  The csv file to anonymize

  Options:
    -d, --delimiter <delimiter> Delimiter to split table by
    -s, --skip-header Ignore (Don't change) first row table
```

### apt-install-temp.sh

```yaml
Install apt packages and marks them as automatically installed (to allow easy removal via apt autoremove)

USAGE:
  apt-install-temp.sh package [package [...]]
```

### bundle-script.sh

```yaml
Bundles a script with it's dependencies (meant to be used for scripts from https://github.com/theCalcaholic/bash-utils)

USAGE:
  bundle-script.sh [OPTIONS] input output [dependency [dependency [...]]]

  input      path to the original script
  output     path to save the bundled script at.
  dependency path to a dependency to bundle

  Options:
    --check, -c If provided, the bundled script will be called with the given arguments to
                check if it works (i.e. returns with exit code 0).
    --gzip, -z  Use additional gzip compression for bundled scripts
    --exit, -e  The expected exit code if the script is working (requires --check)
```

### check-cert.sh

```yaml
Get openssl information on x509_cert_file

USAGE:
  check-cert.sh x509_cert_file
```

### collect-bucket-permissions.sh

```yaml
<No description found>

USAGE:
  USAGE:
  collect-bucket-permissions [OPTIONS]

  Options:
      -p, --project project_id Use the specified project instead of your gcloud default
      -o, --output format Change output format. Can be one of 'yaml', 'spaced', 'spaced-40', 'spaced-80' and 'spaced-120'
      --sa-project For service accounts also print the project which contains it (given the permissions)

Note: You need to be logged into gcloud (gcloud auth login) when executing this command!
```

### collect-service-account-keys.sh

```yaml
<No description found>

USAGE:
  USAGE:
  collect-service-account-keys [OPTIONS]

  Options:
      -p, --project project_id Use the specified project instead of your gcloud default

Note: You need to be logged into gcloud (gcloud auth login) when executing this command!
```

### delete-bridge.sh

```yaml
Deletes given bridge

USAGE:
  delete-bridge.sh bridge-id
```

### du-tool.sh

```yaml
Lists sorted, human-readable sizes of subdirectories

USAGE:
  du-tool.sh [PATH] 
    PATH             The path to analyze
```

### dyndns-update.sh

```yaml
Checks for each configured dynDNS domain if it is pointing at the current ip and otherwise calls an http endpoint for updating it.

USAGE:
  dydns-update.sh
  (Configuration inside the script)
```

### exec-on-change.sh

```yaml
Execute CMD whenever a file within DIR has been changed.

USAGE:
  exec-on-change.sh directory command [OPTIONS]
  directory: Path to watch for changes
  command: Command to execute

  OPTIONS:
    --help, -h: Show this message
```

### fp-nvim-launcher.sh

```yaml
Script to rund the flatpak version of nvim and give it arbitrary permissions for the target (file or directory) path

USAGE:
  fp-nvim-launcher.sh target-path
```

### gcp-list-projects-in-folder.sh

```yaml
Lists all projects contained in a GCP folder or its subfolders

USAGE:
  gcp-list-projects-in-folder.sh folder_id

  folder_id: The id of the root folder that should be searched
```

### gcp-update-project-ssh-key-in-folder.sh

```yaml
<No description found>

USAGE:
  gcp-update-project-ssh-key-in-folder.sh [OPTIONS] command folder user ssh-public-key

  command         'add' if the user/public key should be added to projects where it doesn't exist yet
                  or 'replace' if existing ssh-public-keys for the user should be replaced
  folder          The id of the gcp folder which contains all projects that the ssh public key should
                  be rolled out to
  user            The ssh user
  ssh-public-key  The ssh public key

  Options:
    --blacklist "project1 [project2 [...]]" A space separated list of project ids to not rollout any ssh public keys to
    --non-interactive Ask for confirmation before making any changes (disabling is potentially dangerous!)

```

### gcp-update-project-ssh-key.sh

```yaml
Replaces or updates the ssh key for a specific user in the metadata of a Google Project

USAGE:
  gcp-update-project-ssh-key.sh [OPTIONS] command project-id user ssh-public-key

  command             The command to perform. One of add (adds the key if there wasn't any
                      configured for the given user yet), replace (replaces any old key of the user)
  project-id          The project containing the metadata to edit
  user                The ssh user name of the user of which to replace the public key
  ssh-public-key      The public key to replace the old one with

  Options:
    --non-interactive Don't ask for confirmation before making any changes (potentially dangerous!)
    --help            Show this help message
```

### generate-bash-aliases.sh

```yaml
<No description found>

USAGE:
  generate-bash-aliases.sh > bashrc

  Options:
    --output, -o path File to write to
```

### generate-readme.sh

```yaml
<No description found>

USAGE:
  generate-readme.sh
```

### git-replace-author.sh

```yaml
<No description found>

USAGE:
  git-replace-author.sh [OPTIONS] old-email new-name new-email

  old-email: The email of the author to replace
  new-name: The new author's name
  new-email: The new author's email

  Options:
    -f, --force Overwrite the backup from a previous run
    -h, --help  Show this help message
```

### gs-touch.sh

```yaml
Move file in GCS bucket in order to trigger events (e.g. for cloud functions)

USAGE:
  gs-touch.sh file-uri

  file-uri gs uri for file, e.g. gs://my-storage-bucket/foo.bar
```

### iperf-log.sh

```yaml
Checks the download and upload rates against a given target (where an iperf daemon needs to be running) and prints it in a parseable format together with the current gateway mac address (to allow filtering for networks)

USAGE:
  iperf-log.sh target username rsa-public-key-path

    target: The target IP to test up-/download rates against (requires iperf to be running on the target host)
    username: The username to use for authentication at the target host
    rsa-public-key-path: The path to the public key that will be used for encrypting the iperf credentials

    If the file $HOME/iperf_pw exists, it will be expected to contain a valid iperf password for the target host. Otherwise, the script will ask for the password interactively.
```

### keepass-mounter.sh

```yaml
Script to mount a network (e.g. sshfs/davfs) directory and subsequently start keepass with a vault in said directory

Requires 
  - the flatpak version of KeepassXC to be installed (or whatever version is passed via the -c argument)
  - an fstab entry for the desired mount point (using davfs2)

USAGE:
  keepass-mounter.sh mount-point db-file [OPTIONS]

  mount-point The directory to mount the remote storage into
  db-file     The path to your keepass vault (relative to the mount point)

  Options:
      -b, --backup  A path for storing a database backup
      -c, --command The command for executing keepass (defaults to the flatpak version of keepass).
                    '--DB_PATH--' will be replaced with the path to the password database.
      -h, --help    Show this help message

Example:
  keepass-mounter.sh /media/myUser/keepass myvault.kdbx -b ~/keepass-backups
```

### keepassxc-open-all-urls.sh

```yaml
Interactively open the urls for all passwords within a keepass database file (requires keepassxc.cli)

USAGE:
  keepassxc-open-all-urls.sh [OPTIONS] keepass-db

    keepass-db The path to the keepass database that should be parsed

    Options:
      -b, --browser <browser-command>   The command to launch your browser. Will be called as such: '<command> %url%'
      -c, --cli <keepassxc.cli-command> The command to execute keepassxc.cli. Not required if it can be found in your system PATH
      -g, --group <group-path>          Only show password entries for the given group
      -y, --noninteractive              Open all urls without waiting for user interaction
      -h, --help                        Show this message
```

### lower-vpn-priority.sh

```yaml
Lowers your VPNs default route priority to 101

USAGE:
  lower-vpn-priority.sh [OPTIONS]

  Options:
    -p, --priority <value> Sets the new route priority to the given value (default: 101)

  Must be executed as root
```

### prime-render-offload.sh

```yaml
DESCRIPTION: Executes command with required environment variables to enable NVIDIA prime offload rendering.
USAGE:
  prime_render_offload.sh command [args]
```

### reload_touchpad_driver_lenovo.sh

```yaml
Usage: reload_touchpad_driver_lenovo.sh

  Must be executed as root
```

### setup-secure-dump.sh

```yaml
<No description found>

USAGE:
  USAGE:
  setup-secure-dump [OPTIONS]

  Options:
      -m, --mount mountpoint    The directory to mount the container to 
                                (must be empty or nonexistent)
      -c, --container container The location where the container image should be created
                                (must not exist if -d was not given)
      -d, --delete              Remove an existing container
      -s, --size                The size of the container (e.g. '1G', '500MB')
      -h, --help                Print this help message
```

### show-gcs-bucket-modification-times.sh

```yaml
Shows you the modification times for all buckets in your google project (based on file modification times or as a fallback bucket metadata).

USAGE:
  show_bucket_access [OPTIONS]

Options:
    -f, --fetch   Fetch bucket details before printing update times. If not specified, the details
                  need to be present in the given path (see --dir)
    -p, --project Fetch buckets from given project
    -d, --dir     Specifies the working directory (where the bucket info files will be downloaded
                  to/are expected to be). Default is '.'
```

### start-when-available.sh

```yaml
Start given command as soon as a url can be reached

USAGE:
  Usage: start-when-available [OPTIONS][--delay time] [--batch] [--help|-h] url cmd

  url
    The url that needs to be available before executing the command
  command
    The command to be executed

  Options:
    -d, --delay time A minimum delay (in seconds) after which the command can be executed
    -b, --batch      Use batch mode for executing the command (can help with system resource 
                     consumption)
```

### toggle-ssh-jumpserver.sh

```yaml
<No description found>

USAGE:
  toggle-ssh-jumpserver.sh command user jump-server-name

  command
    'enable' if the jump server should be enabled, else 'disable'
  user
    The user whose ssh config should be edited
  jump-server
    The name of the jump server to use. Needs to correspond to an entry in the user's ssh config
```

### treediff.sh

```yaml
Compare two directory trees

USAGE:
  treediff.sh directory-1 directory-2
```

### virtual-mic.sh

```yaml
Sets up a virtual mic and output to allow e.g. sharing your system sound to a video call (using pulseaudio volume control)
USAGE:
  virtual-mic.sh
```

### whats-my-ip.sh

```yaml
Prints your public IP (by querying opendns or, as fallback, google's dns server)
USAGE:
  whats-my-ip.sh
```

