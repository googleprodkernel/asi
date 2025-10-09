+++
date = '2025-10-09T16:28:47+02:00'
title = 'Resources for ASI'
+++

ASI is a proposed technique for preventing exploitation of a large set of CPU
vulnerabilities. This site is specifically about the Linux kernel feature, an
implementation of which has been developed at Google and deployed on certain
servers.

This site serves to hold info and resources that are useful for the effort to
get this feature into the upstream kernel.

## ASI in a Nutshell

{{% callout note %}}
If you prefer to watch a video, the [recording of the LSF/MM/BPF session from
2024](https://www.youtube.com/watch?v=DxaN6X_fdlI) provides a basic introduction
to ASI. Otherwise, read on.
{{% /callout %}}

The principle is to unmap areas of memory that might contain secrets (i.e. any
data that comes from userspace or a VM guest), even when running kernel code,
until they are needed. They are mapped in on-demand as detected by a page fault.

Accessing an unmapped secret triggers a page fault, whose handler writes to CR3;
this is a serializing instruction, so it prevents speculative access to
sensitive data.

![ASI in a nutshell](asi_nutshell.svg)

Transitions between unrestricted and restricted states provide new hook-points for instantaneous mitigation actions such as:

- Flushing microarchitectural data buffers to block side-channels,
- Flushing control-flow buffers (such as branch predictors) to block
  mistraining,
- Instantaneously pausing ("stunning") hyperthread siblings to prevent
  concurrency-based attacks.

![ASI high-level flow](asi_high_level_flow.svg)

By restricting those actions to the instants where truly needed, ASI hopes to
amortize their cost and thus enable robust mitigations that would otherwise be
too expensive.

![ASI avoids mitigation costs](asi_no_cost.svg)

## Status (Oct 2025)

ASI has been deployed in certain Google environments. No code is upstream yet.
Various prototypes and RFCs have been shared over the years, see the [resources
section](#resources) for details.

Attempts began in earnest to merge code upstream in [Sept
2025](https://lore.kernel.org/all/20250924-b4-asi-page-alloc-v1-0-2d861768041f@google.com/T/#t).

## Resources

### Presentations

-
  [Slides](https://docs.google.com/presentation/u/1/d/1waibhMBXhfJ2qVEz8KtXop9MZ6UyjlWmK71i0WIH7CY/edit?slide=id.p#slide=id.p)
  from LSF/MM/BPF 2025. [LWN coverage of that
  session](https://lwn.net/Articles/1016013/)
-
