# Address Space Isolation for Linux - site source

Source code for ASI resources site, hosted at https://linuxasi.dev.

## Develop

- [Install Nix](https://nix.dev/install-nix#install-nix)
- Run `nix develop`
- Run `hugo server`.

Open the link printed in the terminal.

Start in `content/`.

### Hot-reload

`hugo server` should watch your source tree and regenerate the site when it
changes. It injects JS to refresh the page via a websocket when this happens.
This should work automatically if developing locally.

If developing on a remote server that you can access directly, add
`--bind=0.0.0.0 --baseURL=http://your.server.org` to your `hugo server` command.

If developing on a remote server with some sort of proxy (e.g. a [Google
Cloudtop](https://cloud.google.com/solutions/virtual-desktops) then:

1. Figure out the address your server is proxied on. You might be able to find
   this by running `hugo server --bind=0.0.0.0
   --baseURL=http://your.server.org`, clicking the link it prints, then seeing
   what URL your browser ends up at.

2. Run `hugo server --bind=0.0.0.0 --port=1313 --baseURL="$PROXY_ADDR"
   --appendPort=false` where `$PROXY_ADDR` is the address you found in step 1.

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

## TODOs

- Describe why ASI is useful
- Describe performance targets
- Add some discussion of strategic questions like "allowlist"/"denylist".
