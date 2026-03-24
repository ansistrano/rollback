[![CI](https://github.com/ansistrano/rollback/actions/workflows/ci.yml/badge.svg)](https://github.com/ansistrano/rollback/actions/workflows/ci.yml)

Further details on Ansistrano
-----------------------------

If you want to know more about Ansistrano, please check the [complete Ansistrano docs](https://github.com/ansistrano/deploy/blob/master/README.md)

Testing
-------

The role is tested in GitHub Actions on `ubuntu-latest` with a modern `ansible-core` setup. For local development, use the Docker runner:

```bash
./scripts/test-in-docker.sh syntax
./scripts/test-in-docker.sh integration
```
