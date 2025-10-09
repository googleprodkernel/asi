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

The principle is to unmap areas of memory that might contain secrets (i.e. any
data that comes from userspace or a VM guest), even when running kernel code,
until they are needed. They are mapped in on-demand as detected by a page fault.

Accessing an unmapped secret triggers a page fault, whose handler writes to CR3;
this is a serializing instruction, so it prevents speculative access to
sensitive data.

![ASI in a nutshell](asi_nutshell.svg)
