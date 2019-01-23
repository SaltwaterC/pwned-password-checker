# pwned-password-checker

Offline search into a pwned password list. Uses the index created by [pwned-password-tools](https://github.com/SaltwaterC/pwned-password-tools) pwned-password-indexer.

## Install (not done yet)

  gem install pwned-password-checker

## Usage

```bash
# built in help
pwned-password-checker -h
Usage:
    pwned-password-checker           to check a single password

    -p, --pwn pwned-passwords.txt    Path to pwned passwords file. Defaults to ~/.pwn/pwned-passwords-sha1-ordered-by-hash-v4.txt
    -i, --index ~/.pwn/idx           Path to the directory where the index is going to be written. Defaults to ~/.pwn/idx
    -q, --quiet                      Whether to turn on quiet mode which suppress the password prompt
    -h, --help                       Show this help

# search single password using default options
pwned-password-checker
password> foo
Hash: 0BEEC7B5EA3F0FDBC95D0DD47F3C5BC275DA8A33
This password has been seen 5190 times before
Seek time: 5.59 ms

# search single password in quiet mode
pwned-password-checker --quiet
password>
Hash: 0BEEC7B5EA3F0FDBC95D0DD47F3C5BC275DA8A33
This password has been seen 5190 times before
Seek time: 7.07 ms
```

## TODO

 * Implement bulk mode for password databases:
  * KeePass V2 database format (KeePass 2, KeePassX, KeePassXC, etc)
  * OPVault database format (1Password)
  * Bitwarden (requires bit of research - may not happen)
 * Publish as a gem
