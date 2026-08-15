# Branch conventions

How this organisation names things in Git. Short, because a convention nobody can recite is not one.

## Branches

`<kind>/<subject>`, lower case, hyphenated. `kind` is one of `feat`, `fix`, `chore`, `docs`.

The subject names the outcome, not the mechanism: `fix/token-in-persisted-record`, not
`fix/regex-update`. Six months later the mechanism is gone and the outcome is what someone searches
for.

One branch, one reviewable change. If the branch needs an "and" in its subject, it is two branches.

## Commits

The subject line is a sentence in the present tense that says what the commit makes true —
*"The record no longer carries the token"* — and it is under 72 characters. The body says why, and
why is the part a diff cannot show.

No commit references a ticket and nothing else. A ticket can be deleted; a commit message is
permanent.

## Tags

`vMAJOR.MINOR.PATCH`. Tags are never moved and never deleted. If a tag is wrong, the fix is the
next tag, plus a note saying what the wrong one was.

A tag is the input to every build that claims to come from it, so builds check out the tag by name
rather than the branch that happens to point at it today.

## Main

`main` is always releasable. Everything reaches it through a pull request, and the pull request is
green before it merges — not green afterwards, when somebody remembers to look.
