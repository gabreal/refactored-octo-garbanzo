
# refactored-octo-garbanzo

No secrets at all.


Initialize the repo with the key on first checkout:

```
git-crypt unlock /path/to/keyfile
```



Thanks a lot to [git-crypt](https://www.agwa.name/projects/git-crypt/).




### secrets.tf.json

```json
{
  "variable": {
    "passphrase": {
      "default": "A passphrase"
    },
    "repo_keyfile": {
      "default": "A key location"
    }
  }
}
```

It'll then be better parsable on the commandline e.g.

```
jq -r '"passphrase=\"" + .variable.passphrase.default + "\"" ' < secrets.tf.json
```


