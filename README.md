# pwned-password-checker

Offline search into a pwned password list. Uses the index created by [pwned-password-tools](https://github.com/SaltwaterC/pwned-password-tools) pwned-password-indexer.

Supports:

 * single password check
 * bulk password check:
  * KDBX format via [rubeepass](https://gitlab.com/mjwhitta/rubeepass)
  * 1Password vaults via [op CLI](https://support.1password.com/command-line/) - you must first authenticate with `op signin <subdomain>` before `op signing` works as expected without explicit arguments

## Install (not done yet)

  gem install pwned-password-checker

## Usage

```bash
# built in help
pwned-password-checker --help
Usage:

pwned-password-checker                       checks a single password
pwned-password-checker --bulk kdbx           bulk check of a KDBX file
pwned-password-checker --bulk onepassword    bulk check of 1Password vaults

    -p pwned-sha1-passwords.txt,     Path to pwned passwords file. Defaults to ~/.pwn/pwned-passwords-sha1-ordered-by-hash-v7.txt
        --pwn
    -i, --index ~/.pwn/idx           Path to the directory where the index is going to be written. Defaults to ~/.pwn/idx
    -e, --echo                       Whether to turn on the password output in the prompt
    -b, --bulk kdbx|onepassword      Turns on bulk checking against supported backends: kdbx, onepassword
    -h, --help                       Show this help
```

```bash
# search single password
pwned-password-checker
password>
Hash: 0BEEC7B5EA3F0FDBC95D0DD47F3C5BC275DA8A33
This password has been seen 5190 times before
Seek time: 7.07 ms
```

```bash
# search single password using echo mode
pwned-password-checker --echo
password> foo
Hash: 0BEEC7B5EA3F0FDBC95D0DD47F3C5BC275DA8A33
This password has been seen 5190 times before
Seek time: 5.59 ms
```

```bash
# bulk search in KDBX file (KeePass 2.x KDBX v4 format)
# pwn.kdbx is a test file of pwned-password-checker with password 'pwn'
pwned-password-checker --bulk kdbx
KDBX path> spec/files/pwn.kdbx
KDBX password>
KDBX key file>
+-------+-------+----------+----------+-------+
|               Pwned passwords               |
+-------+-------+----------+----------+-------+
| Group | Title | Username | Password | Count |
+-------+-------+----------+----------+-------+
| foo   | bar   | baz      | qux      | 15    |
+-------+-------+----------+----------+-------+
```

## TODO

 * Implement bulk mode:
  * Bitwarden (requires bit of research - may not happen)
  * Plaintext list of passwords
 * Publish as a gem
