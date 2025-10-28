# Address Space Isolation for Linux - site source

Source code for ASI resources site, hosted at https://linuxasi.dev.

## Develop

- [Install Nix](https://nix.dev/install-nix#install-nix)
- Run `nix develop`
- Run `hugo server`

Open the link. The result should auto-reload when you change the code.

Start in `content/`.

### Images

Put them in `static` and then use their path relative to that dir:

```markdown
![ASI in a nutshell](asi_nutshell.svg)
```

### Callouts

These are implemented with a Hugo thing called
[shortcodes](https://gohugo.io/content-management/shortcodes/). Use it like this:

```markdown
{{< callout >}}
hello
{{< /callout >}}
```

The rendering of this is defined via
`themes/asi/layouts/shortcodes/callout.html`. It can be made more complicated if
needed.
