# A worked example

Excerpts from a real brief, chosen to show the four moves that are hard to get right. The subject is
a tool that installs AI artifacts into agentic harnesses; nothing about the technique depends on that.

## The verdict, first, with its blockers named

> **Hold it for three fixes.** Not because the release is unsound — 1528 tests pass, nine gates are
> green, and the schema freeze proves no boundary moved — but because all three land on the exact
> feature the release is named after, and each is small.
>
> | | Finding | Why it blocks *this* release specifically |
> |---|---|---|
> | 1 | `LAF-63` | A credential in free text is persisted unredacted, and `receipt show` is the command that prints it |
> | 2 | `LAF-66` | `receipt verify` answers `true` about a directory it never looks in |
> | 3 | `LAF-65` | The receipt tells the operator no command reverses a setup, in the release that ships one |

The third column is doing all the work. Each of these had been open before, and none was a blocker
until this release shipped the command that met it.

## Severity argued from behaviour, not from source

> Redaction anchors on `\b(token|password|secret|api_key)`, and in `GITHUB_TOKEN` there is no word
> boundary before `TOKEN`. Measured:
>
> ```
> REDACTED  TOKEN=ghp_aaa             -> TOKEN=[redacted]
> LEAKED    GITHUB_TOKEN=ghp_bbb      -> GITHUB_TOKEN=ghp_bbb
> LEAKED    AWS_SECRET_ACCESS_KEY=s2  -> AWS_SECRET_ACCESS_KEY=s2
> ```
>
> The prefixed forms are the ones real recipes use.

Six lines that a reader can re-run. Compare with *"the redaction regex has a word-boundary bug"*,
which asks them to trust you.

Note also what the same paragraph goes on to concede: mapping *keys* are matched by substring and are
safe. Naming the half that works is what makes the half that doesn't credible.

## A priority that looks wrong, explained where it appears

> **`LAF-69` is high and P2, which is the combination worth explaining.** Its blast radius is large —
> it is the gate that decides whether the release documents can be trusted — but it fired once, was
> caught by a human within minutes, and the fix is a design question rather than a predicate change:
> making the rule symmetric means teaching it to read a disposition out of prose, which is the thing
> the register exists to stop documents doing. Fix it deliberately, not quickly.

Without that paragraph a reader sees `high / P2` and concludes the numbers are decorative.

## The correction left visible

> This is also the first place I got the facts wrong while writing this brief: I read both registries'
> pins out of local working trees, and both were sitting on branches that disagreed with `origin/main`
> — one seven commits behind, one *on* the unmerged PR. The corrected numbers are above.

The wrong reading is more useful to the reader than a clean table would have been, because it names
the trap. The corrected state was then given as a table with one row per repository, which is what
made the pattern — *every version-move is prepared and none lands* — visible as a finding of its own.

## And the closing sections

> ## If you only do one thing
>
> `LAF-63`. It is the only finding here where the failure mode is *a secret on disk and on a
> terminal*, the fix is a regex and its tests, and the test that proves it is already written and
> currently asserting the broken behaviour.

Value per unit cost, in one paragraph, with the cost stated. A reader in a hurry can stop here and
still act correctly, which is the property a brief is for.
