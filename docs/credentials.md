# Local credentials

Two files are needed to run a project locally:

| File | What it unlocks |
|---|---|
| `org.env` | License keys and policy flags — ACF Pro, Gravity Forms, WP Migrate, Postmark |
| `auth.json` | Composer credentials for the private package repository |

Situation developers get both automatically from the org repositories. Everyone
else is given the files directly through secure delivery, and places them by
hand — once per machine.

## Where to put them

Create the directories if they do not exist, then drop the files in:

```
~/.ddev/homeadditions/.sitchco/org.env
~/.ddev/homeadditions/.composer/auth.json
```

DDEV copies `~/.ddev/homeadditions/` into every project's container on every
start, so this is a one-time placement that survives restarts, rebuilds, and
`make update`.

Then start the project:

```shell
make start
```

To confirm the files were picked up:

```shell
ddev secrets-check
```

## Scoping to a single project

If one project needs different credentials than the rest of the machine — for
example a site whose organization runs its own license keys — place them in the
project instead:

```
<project>/.conf/org.env
<project>/.conf/auth.json
```

A project file always wins over the machine-wide drop. Both are gitignored, and
`.conf/` is denied to the web server, but treat them as credentials: they are
inside the webroot, and only an Apache rule keeps them from being served.

## Resolution order

Both `ddev org-env` and `ddev composer-auth` try these in turn and stop at the
first hit:

1. `.conf/` in the project
2. `~/.ddev/homeadditions/` on the machine
3. A clone from the Situation org repository

Because a provided file wins over the clone, an organization running its own
keys never needs Situation org access. The tradeoff is that a provided file is
authoritative and never refreshes — when keys rotate, replace the file. Run
`ddev secrets-check` to see which source is actually in use.

## Situation developers

Nothing changes. Load your ssh agent and run:

```shell
ddev auth ssh
```

`make start` does this for you. If you have previously dropped a file into
`.conf/` or `homeadditions/`, that file takes precedence over the org clone —
remove it to go back to the org copy.
