# ripple

RIDE + Perl = Ripple. A minimal client for Dyalog APL's [RIDE](https://github.com/Dyalog/ride) protocol.

Connects to a running Dyalog session, executes expressions, disconnects. One file, no dependencies beyond core Perl.

**Why?! No seriously... WHY?!**

It may be the case that you want to administer a Dyalog session exposing the
RIDE port, but all you have is an impoverished and simple machine. That is, one
without a RIDE client of any sort.

On POSIX and POSIX-ish systems Perl is _ubiquitous_. A small review showed that
even RHEL 9 comes with Perl 5.32, which is nice and very modern.

The solution: a 2KB RIDE implementation in Perl. As Perl is guaranteed on
everything but Windows (WSL exists though), and the author knows Perl, it was an
obvious choice. No installing an untrusted binary; no installation at all. One
small script.

## Usage

```
ripple [-addr host:port] [-e 'expr'] ...
```

Default address is `localhost:4502`.

### Inline expressions

```sh
ripple -e "⎕←2+2"
ripple -e "⎕SE.Link.Create '#' '/app/src'" -e "#.Run 'Multi'"
```

### Remote session via SSH

Just an example from how I've used it:

```sh
ssh -L 14502:localhost:4502 user@server
ripple -addr localhost:14502 -e "⎕←⎕WA"
```

## Requirements

Perl 5.32+ (ships with RHEL 9, Debian 11, Ubuntu 22.04, and anything newer). Uses only `IO::Socket::INET` from core.

## Install

There is no install. `ripple` just works. You may need to `chmod +x` depending
on your setup.

## What are these other files?

`ripple-min`, `ripple-packed`, etc are experiments in getting silly about
minification - **ignore them**. I will decide how best to minify. `minify.pl` is the script used to create them.

If you refuse to ignore, ripple-min.gz is nice. <800 bytes and can be piped in
to perl (gzip is also POSIX standard):

```
gzip -dc ripple-min.gz | perl - -e "⎕←747753"
```

## How it works

The RIDE protocol runs over raw TCP with a simple framing format: `[4-byte big-endian length][RIDE + payload]`. Ripple performs the protocol handshake (`SupportedProtocols`, `UsingProtocol`, `Identify`, `Connect`), waits for the interpreter to be ready, then sends `Execute` commands sequentially — waiting for each to complete before sending the next. Then it closes the connection, leaving the Dyalog session running.

## Licence

MIT
