# Proposal: change-backlog-status-cleanup

## Summary

Classify existing package changes with a durable status and refresh stale workflow-scale evidence references.

## Problem

Historical tasks are complete, but QA/release/archive evidence coverage is uneven and some local evidence is stale.

## Goals

- Track every existing change as `active`, `complete`, `archived`, or `superseded`.
- Record evidence gaps without claiming unverified completion.
- Refresh workflow-scale status so completed child changes are no longer described as future work.
