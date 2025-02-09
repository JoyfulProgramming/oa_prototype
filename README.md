# Prototype for OA

OA client for Ruby.

## Getting Started

```bash
bin/setup
```

Needs `rbenv`.

## Tests

```bash
bin/test
```

## Serve

```bash
bin/serve                     # Development mode - connects to in memory agent
RACK_ENV=production bin/serve # Production mode - expects agent to be running
```

## Deploy

```bash
bin/deploy
```

Needs private key at `~/.ssh/id_rsa_hertzner_dynatrace_agent`.

## Console

```bash
bin/console # ssh to server and run arbitrary commands
```

Needs private key at `~/.ssh/id_rsa_hertzner_dynatrace_agent`.
