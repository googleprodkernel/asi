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

{{< callout >}}
If you prefer to watch a video, the [recording of the LSF/MM/BPF session from
2024](https://www.youtube.com/watch?v=DxaN6X_fdlI) provides a basic introduction
to ASI.

If you prefer a more detailed exegesis, see the [resources section](#resources).
More recent iterations include documentation patches that might be illustrative.
{{< /callout >}}

The basic idea of ASI is to introduce a new kernel address sapce that doesn't
contain any user data (userspace process memory or KVM guest memory). This new
address space is called the **nonsensitive** address space; other than having
user data unmapped it's exactly the same as the normal kernel address space,
which is called the **sensitive** address space.

{{< callout >}}
**Note**: Earlier ASI resources used the term "restricted" and "unrestricted" to
describe the nonsensitive and sensitive address spaces respectively.
{{< /callout >}}

As much as possible, the kernel runs in the nonsensitive address space. Since
speculative execution can't access unmapped data, all data is fully protected
from transient execution attacks during this time. When the kernel _does_ need
to access user data, this access triggers a page fault. In the page fault
handler, the kernel switches to the sensitive address space and then continues,
so that the faulting memory access is retried and succeeds and execution
continues. This fault-driven approach means ASI is transparent to most of the
kernel; only very low-level code needs to be aware of the two separate address
spaces.

![ASI in a nutshell](asi_nutshell.svg)

Transitions between sensitive and nonsitive states provide new hook-points for
instantaneous mitigation actions such as:

- Flushing microarchitectural data buffers to block side-channels,
- Flushing control-flow buffers (such as branch predictors) to block
  mistraining,
- Instantaneously pausing ("stunning") hyperthread siblings to prevent
  concurrency-based attacks.

![ASI high-level flow](asi_high_level_flow.svg)

By restricting those actions to the instants where truly needed, ASI amortizes
their cost and thus enable robust mitigations that would otherwise be too
expensive.

![ASI avoids mitigation costs](asi_no_cost.svg)

When it's working well, ASI is faster than Linux's existing mitigations, while
being much more general and flexible. For example, while Google saw CPU
overheads on the order of 5% when evaluating upstream mitigations for
[SRSO](https://docs.kernel.org/admin-guide/hw-vuln/srso.html), ASI's overheads
almost always stay below 1% of whatever endpoint is being measured.

This website will be updated with more detailed performance information as time
goes on. Please contact Brendan Jackman via the address you'll find on LKML if
you have specific questions or workloads you're interested in evaluating.

## Status (Oct 2025)

ASI has been deployed in certain Google environments. No code is upstream yet.
Various prototypes and RFCs have been shared over the years, see the [resources
section](#resources) for details.

Attempts began in earnest to merge code upstream in [Sept
2025](https://lore.kernel.org/all/20250924-b4-asi-page-alloc-v1-0-2d861768041f@google.com/T/#t).

## Resources

### Presentations

The next presentation will be at [LPC 2025](https://lpc.events/event/19/program)
at the x86 microconference.

Most recent first:

- [Slides](https://docs.google.com/presentation/u/1/d/1waibhMBXhfJ2qVEz8KtXop9MZ6UyjlWmK71i0WIH7CY/edit?slide=id.p#slide=id.p)
  & [LWN coverage](https://lwn.net/Articles/1016013/) from LSF/MM/BPF 2025.
- [Slides](https://lpc.events/event/18/contributions/1761/attachments/1549/3230/ASI%20LPC2024.pdf)
  & [recording](https://www.youtube.com/watch?v=uzJ-Z4dzT0c) from LPC 2024.
- [Recording](https://www.youtube.com/watch?v=DxaN6X_fdlI) & [LWN
  coverage](https://lwn.net/Articles/974390/) from LSF/MM/BPF 2024. **This
  session included a basic conceptual intro to ASI**.

### Code & LKML discussions

The most up-to-date ASI code is the [`asi/next` branch on Brendan Jackman's
Github repository](https://github.com/bjackman/linux/tree/asi/next). This is
currently (Oct 2025) in a very messy state, it will be updated in coming weeks
with more info added to this site.

Most recent first:

- Sept 2025: [`[PATCH 00/21] mm: ASI direct map management`](https://lore.kernel.org/all/20250924-b4-asi-page-alloc-v1-0-2d861768041f@google.com/T/#t)

  This is the first `[PATCH]` posting, i.e. the first code that's been presented
  as more than a prototype or proof-of-concept.

  This was an attempt to introduce basic pagetable management without the actual
  address-space-switching logic. Feedback from Dave Hansen suggests this is the
  wrong approach to getting ASI merged:

  > Just to be clear: we don't merge code that doesn't do anything
  > functional. The bar for inclusion is that it has to do something
  > practical and useful for end users. It can't be purely infrastructure or
  > preparatory.

- Aug 2025: [`[Discuss] First steps for ASI (ASI is fast
  again)`](https://lore.kernel.org/all/20250812173109.295750-1-jackmanb@google.com/)

  This introduces a proof-of-concept for how to solve performance issues with
  the page cache. It attempts to generate a consensus on whether the kernel
  wants ASI, at least in principle.

  Discussion centers on implementation of that solution. Lorenzo Stoakes
  suggests "we should just get going with some iterative series".

- Jan 2025: [`[PATCH RFC v2 00/29] Address Space Isolation
  (ASI)`](https://lore.kernel.org/linux-mm/20250110-asi-rfc-v2-v2-0-8419288bc805@google.com/)

  A general proof-of-concept patchset introducing a minimal implementation of
  ASI. Compared to previous iterations, the key addition is support for
  protection against native processes (not only VM guests).

- July 2024: [`[PATCH 00/26] Address Space Isolation (ASI)
  2024`](https://lore.kernel.org/linux-mm/20240712-asi-rfc-24-v1-0-144b319a40d8@google.com/)

  Compared to previous patchsets, this is just a simplification, attempting to
  make technical discussion more practical by shrinking the scope.

  There is some discussion of implementation details.

- Feb 2022: [`[RFC PATCH 00/47] Address Space Isolation for
  KVM`](https://lore.kernel.org/all/20220223052223.1202152-1-junaids@google.com/)

  This is Google's first public posting of ASI. (Note, this was not the first
  implementation of this feature, see the references of that post for more
  history).
