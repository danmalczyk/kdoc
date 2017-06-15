## Kylo dev image
The kylo docker image is based on the kylo image, and it replaces the kylo-*.jars found in /opt/kylo (depending on the configured modules)

## Configuration

[`scripts/config.sh`](scripts/config.sh) contains the user configuration. Follow the comments

## Build image

Don't forget to **build your kylo maven project**. It fails silently if a folder/jar is missing.

```
make

# or without cleaning:
make build
```

## Start dev stack

```
cd ..
make start-dev
```

## Stop dev stack
Same as stop stack
