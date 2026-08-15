---
name: release-evidence
description: Make a release provable rather than asserted — pin the artifact you publish to the commit you tagged, and verify the published bytes after publishing. Use when cutting a release, attaching a build artifact, writing release notes, or checking that a published release matches its source.
---

# Release evidence

A release is a claim: *these bytes come from that commit*. Most release processes assert it. This
one makes it checkable, because the two ways it goes wrong are both invisible from the inside.

## The two failures

**The artifact is not the one you measured.** A digest printed by one command and an artifact built
by another are the same file only by coincidence. If the build stamps anything — a commit, a date, a
version — then the checkout you built from is part of the input, and building from a branch after
tagging produces a third file that matches neither.

**The notes describe a different release.** Release notes are written before the release and read
after it. Everything they say about known defects is a claim about the state of the code at the
moment of tagging, and nothing checks it, because release notes are usually excluded from whatever
gates the rest of the documentation.

## The procedure

1. **Tag first, then build.** Check out the tag by name, not the branch that points at it.
2. **Build and hash in one step.** If the tool that prints the digest throws its artifact away,
   make it keep the artifact, or build the artifact and hash it yourself — never take a digest from
   one command and an upload from another.
3. **Write the digest into the notes** before publishing, so the claim is public.
4. **Publish.**
5. **Download what you published and hash it.** Not the local file; the one the world can get. This
   is the only step that can catch step 2 being wrong, and it costs one command.
6. **Gate the notes while they are unpublished.** A release note is the most current document in the
   repository until the moment it ships, and a dated record afterwards. Check it against your issue
   register while it is the first, and stop the moment it becomes the second.

## What this does not do

It does not tell you the release is good. It tells you the release is the thing you looked at.
Everything about whether that thing works belongs to your tests.

See [references/verification-checklist.md](references/verification-checklist.md) for the commands.
