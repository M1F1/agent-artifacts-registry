# Verification checklist

Adapt the command names; the order is the part that matters.

## Before publishing

```
git checkout <tag>            # the tag, never the branch
<build>                       # from this checkout, keeping the artifact
<hash the artifact>           # the digest that goes into the notes
```

If your build and your digest come from different commands, prove they agree once and record how:
a digest whose provenance nobody can restate is a number, not evidence.

## After publishing

```
<download the published artifact>
<hash it>
```

Compare against the digest in the notes. A mismatch here means the upload was wrong, and finding it
now costs a re-upload; finding it later costs an advisory.

## The notes

Check them against your open-issue register while they are unpublished. Every sentence of the form
*known defect, shipped open* is a claim that some other document can contradict. Remove them from
the gate the day they ship — a dated record is allowed to disagree with the present, and editing it
until it agrees destroys the evidence it exists to be.
