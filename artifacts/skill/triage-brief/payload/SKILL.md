---
name: triage-brief
description: Turn a register of open findings into a decision brief — severity, priority, and the feature each finding breaks — so someone can decide what to fix and whether to release. Use when asked what is broken, what to fix first, whether a release is worth shipping, or to produce a status brief from an issue register or residue register.
---

# Triage brief

A register says *what is open*. A brief says *what it costs and what to do about it*. They are
different documents and conflating them produces the thing everyone has read and nobody has acted
on: a list, sorted by id, with a severity column that means nothing.

This skill produces a brief someone can decide from.

## What a brief is for

One reader, one decision. Before writing anything, name both:

> *The maintainer decides whether 2.6.0 ships this week.*

If you cannot write that sentence, you are writing a register, not a brief. Stop and write the
register instead — it is a different and also useful document.

Everything in the brief either serves that decision or is cut. A finding that cannot change the
answer still gets a row, because *"nothing here is a surprise"* is information, but it does not get a
paragraph.

## The three columns that matter

### Feature — group by what a user would say is broken

**This is the load-bearing choice.** Group by the promise the product makes, not by module, layer, or
who found it. A reader decides per feature: *do I trust uninstall?* is a question someone can answer;
*do I care about `application.py`?* is not.

Write the feature as the sentence a user would say:

> ### Install and uninstall hygiene — *"uninstall leaves nothing behind"*

Two findings in the same feature that are the same defect should say so. Two in different features
that share a root cause should each appear where a user meets them, cross-referenced. The reader is
deciding about features; the causal graph is your problem, not theirs.

### Severity — what it costs when it bites

A property of the defect, independent of anything else. Three levels; more is false precision.

| | Meaning |
|---|---|
| **high** | A secret escapes, state is lost, or a command reports success or `true` when the opposite is true |
| **medium** | The product promises something in its own UI or docs that the code does not do; a human can recover by hand |
| **low** | Friction, dead code, or an undocumented limit; nothing is wrong, something is unhelpful |

A command that **confidently reports a false negative** is high, not medium. A verifier that passes
what it never looked at is worse than no verifier, because it converts a gap into a claim of safety.
Grade it that way even when the underlying gap is small.

### Priority — when to spend on it

Severity, plus how likely it is to be met, plus what the fix costs.

| | Meaning |
|---|---|
| **P1** | Before the next release. It lands on a feature that release advertises |
| **P2** | Next stream. Real, met by real users, not on the current release's face |
| **P3** | When that area is next opened. Correct to fix, wrong to open the file for |

**high/P3 is not a contradiction and must be explained where it appears.** It means the blast radius
is large but the path is narrow and nobody is standing on it. A reader who sees an unexplained
high/P3 concludes the numbers are decorative, and then ignores all of them.

## The rules

### Read the state you are claiming about, from where it actually lives

Working trees lie. A repository sitting on a stale branch, or on the very branch whose merge you are
about to report as pending, will answer a `grep` confidently and wrongly.

- For a claim about a repository's `main`, read `origin/main`, not the checkout: `git fetch` first,
  then `git show origin/main:<path>`.
- For a claim about what is installed, read the installed distribution's metadata — not `--version`
  alone, and never `importlib.metadata` from a directory that contains the source tree, which will
  answer with a stale `*.egg-info` from `sys.path[0]`.
- For a claim about an open pull request, ask the forge (`gh pr list`), not a local branch's
  existence.

Every one of those has produced a wrong row.

### Measure the failure, do not describe the code

A row that says *the regex lacks a word boundary* is a claim about source. A row that says this:

```
REDACTED  TOKEN=ghp_aaa             -> TOKEN=[redacted]
LEAKED    GITHUB_TOKEN=ghp_bbb      -> GITHUB_TOKEN=ghp_bbb
```

is a claim about behaviour, and the reader can check it in ten seconds. Prefer the second. Where a
finding is high severity, the brief should carry the measurement, not a description of it.

### Correlate the finding with the release, not only with the feature

The decision is usually *ship or hold*, so for each candidate blocker answer one question: **does
this land on what this release is named after?** A defect that has been open for three releases
becomes a blocker the moment the new release ships the command that exposes it. That intersection is
the most valuable sentence in the brief and it is never in the register, because the register has no
concept of "this release".

### State the cost of the fix, not just the defect

*"The fix is the regex plus its tests, and the test that proves it is already written and currently
asserting the broken behaviour"* changes a decision. *"Should be fixed"* does not. If you do not know
the cost, say you do not, and say what it would take to find out.

### Do not round up

If two of seven acceptance criteria were never walked, the brief says two of seven were never walked.
A brief that reports the good half is worth less than no brief, because the reader now has to verify
it, which is the work you were doing for them.

### Write it so a tired reader understands it on the first pass

A brief is read by someone deciding under time pressure, often not in their first language. Writing
that sounds good and reads slowly is a failure of the brief, not a matter of taste.

- Short sentences. One idea each.
- Plain words. *Blast radius* → *how many people it affects*. *Falsifies* → *makes wrong*.
- Say the thing, then explain it. Not the reverse.
- For anything important, use the same three headings every time: **What goes wrong**, **Why it
  matters**, **Cost to fix**. Repetition is a feature; the reader learns the shape once.
- No irony, no rhetorical questions, no clever contrasts. They cost the reader a re-read.
- Show a measurement as a small block of before/after lines, not as a sentence about a measurement.

Test it: read your own headings only. If they alone tell someone what to do, the brief works. If the
meaning is hidden inside the paragraphs, rewrite the headings.

### Correct in place, and say you corrected

When you get a fact wrong mid-brief, fix the row and add a line saying which fact was wrong and why.
A brief with a visible correction is more trustworthy than one without, and the *why* is often itself
a finding — a stale working tree, a version read from the wrong place.

## Shape

```
# Triage brief — <the decision>

Derived from <register> on <date>. The register says what is open; this brief says
what it costs. When they disagree, the register is right and this file is stale.

## Verdict                     <- the answer, first, with the 2-4 findings that drive it
## How to read the two numbers <- severity and priority tables, every time
## By feature                  <- one section per feature; table, then prose only where it earns it
## If you only do one thing    <- the single highest value-per-cost fix
## If you want <X> by <when>   <- the minimum set for a named outcome
```

**Verdict first.** The reader came for the answer. A brief that opens with methodology is a report.

**Prose only where it earns it.** Most rows are a table line. A row gets a paragraph when the
severity is high, when the priority looks wrong without explanation, or when two findings are
secretly one.

**Date it and name its source.** A brief is a snapshot and goes stale by design. Say so at the top so
nobody maintains it in parallel with the register — two lists is how the first one stops being true.

## Anti-patterns

| Don't | Because |
|---|---|
| Sort by id | Ids are chronological; nobody decides chronologically |
| Group by module | The reader does not have your module map |
| One severity scale for everything | Then severity is a synonym for priority and one of them is noise |
| A "recommendations" section at the end | The recommendation *is* the brief; a separate section means the rest was throat-clearing |
| Copy the register's rows | If the brief adds nothing to a row, the row belonged in the register alone |
| Omit findings that make the work look bad | The unwalked criteria and the wrong pins are the rows the reader most needs |

## When you are done

Check the brief against its own decision: read the verdict, then read the tables, and ask whether the
tables would let a reader reach a *different* verdict. If they cannot, you have written an argument
and called it a brief. Put back what you cut.
