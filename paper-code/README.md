# paper-code/

Original figure code from each reproduced paper, pinned to its
publication commit. Two ways to populate, per post:

## Option A — git submodule (preferred when the repo is clean)
```bash
git submodule add https://github.com/traitecoevo/<paper-repo> paper-code/<slug>
cd paper-code/<slug> && git checkout <publication-tag-or-sha> && cd -
git add .gitmodules paper-code/<slug>
git commit -m "pin <slug> paper code at <ref>"
```
CI checks these out with `submodules: recursive`. Record the same ref in
the post's `paper.code-ref` front-matter field so the badge matches.

## Option B — vendored snapshot (when the repo is heavy/unfetchable)
Copy only the figure script + its inputs into `paper-code/<slug>/`, and
still record the upstream `code-ref` in front matter for provenance.

The post's "paper code, today" chunk sources `<code-entrypoint>` from
here; the "current plant" chunk uses the live API. Comparing the two is
the regression signal.
