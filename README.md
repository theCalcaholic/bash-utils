# A collection of scripts I have written over the years
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
Install apt packages marked as 'auto'

USAGE:
  apt-install-temp package [package [...]]
```

### bundle-script.sh

```yaml
Bundles a script with it's dependencies (meant to be used for scripts from https://github.com/theCalcaholic/bash-utils)

USAGE:
  bundle-script.sh input output

  input:  path to the original script
  output: path to save the bundled script at.
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
  exec-on-change.sh DIR CMD [OPTIONS]
  DIR: Path to watch for changes
  CMD: Command to execute

  OPTIONS:
    --help, -h: Show this message
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

  command:        'add' if the user/public key should be added to projects where it doesn't exist yet
                  or 'replace' if existing ssh-public-keys for the user should be replaced
  folder:         The id of the gcp folder which contains all projects that the ssh public key should
                  be rolled out to
  user:           The ssh user
  ssh-public-key: The ssh public key

  Options:
    --blacklist  A space separated list of project ids to not rollout any ssh public keys to
  
```

### gcp-update-project-ssh-key.sh

```yaml
Replaces the ssh key for a specific user in the metadata of a Google Project

USAGE:
  gcp-replace-project-ssh-key.sh command project-id user ssh-public-key

  command:        The command to perform. One of add (adds the key if there wasn't any
                  configured for the given user yet), replace (replaces any old key of the user)
  project-id:     The project containing the metadata to edit
  user:           The ssh user name of the user of which to replace the public key
  ssh-public-key: The public key to replace the old one with
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
  git-replace-author.sh old-email new-name new-email

  old-email: The email of the author to replace
  new-name: The new author's name
  new-email: The new author's email
```

### gs-touch.sh

```yaml
<No description found>

USAGE:
  Move file in GCS bucket in order to trigger events (e.g. for cloud functions)
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

Example:
  keepass-mounter.sh /media/myUser/keepass myvault.kdbx -b ~/keepass-backups
```

### lower-vpn-priority.sh

```yaml
Lowers your VPNs default route priority to 101

USAGE:
  lower-vpn-priority.sh
  Requires
```

### prime-render-offload.sh

```yaml
### reload_touchpad_driver_lenovo.sh

```yaml
### setup_secure_dump.sh

```yaml
### show-gcs-bucket-modification-times.sh

```yaml
### start-when-available.sh

```yaml
### toggle-ssh-jumpserver.sh

```yaml
### treediff.sh

```yaml
### virtual-mic.sh

```yaml
### weaken_vpn.sh

```yaml
### whats_my_ip.sh

```yaml
