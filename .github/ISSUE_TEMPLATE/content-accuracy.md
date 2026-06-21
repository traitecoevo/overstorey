---
name: Content accuracy / model drift
about: A page's science, code, or a figure looks wrong, stale, or no longer matches plant.
title: "[accuracy] <page title> — <what's wrong>"
labels: [bug, documentation]
---

<!--
Use this when content is factually wrong, uses a stale plant API, or a figure
no longer matches what plant produces today. Overstorey pages are pinned to a
plant version/commit and rendered from a committed _freeze/, so please note the
pin if you can — it tells us whether this is content drift or model drift.
-->

### Which page?
<!-- Page title + URL -->

-

### plant pin on the page (if known)
<!-- From the page's version badge or front matter:
     plant-version: "..."  OR  plant-ref: "develop" + plant-sha: "..." -->



### What's wrong?
<!-- The incorrect statement / equation / API call / figure, and what it should be. -->



### Evidence
<!-- A working code snippet, the correct API signature, the expected figure,
     a paper reference, or a link to the relevant plant source/commit. -->



### Category
- [ ] Stale plant API (code no longer runs / wrong arguments)
- [ ] Incorrect maths or description
- [ ] Figure no longer reproduces (model drift)
- [ ] Broken/incorrect link or cross-reference
- [ ] Other
