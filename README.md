# ansible-test

A collection of docker-compose scripts to run ansible tests.
There are 6 compose commands to run:
- sanity tests on python 2.7
- sanity tests on python 3.5
- integration tests in any number of docker containers
- unit tests in fedora28 container
- manual (interactive) shell with python 2.7 environment
- manual (interactive) shell with python 3.5 environment

## requirements

1. Docker installed and running with /var/run/docker.sock used to communicate with daemon
2. docker-compose installed locally

## prepare

1. Clone this repo:
    ```bash
    git clone git@github.com:astorath/ansible-test.git
    cd ansible-test/
    ```
2. Replace submodule reference with your own fork:
    ```bash
    git submodule deinit --force ansible/
    git rm --force ansible/
    git submodule add -b <your_feature_branch> --force <your_ansible_fork> ansible/
    ```

3. Add `.env` file to the root of repository and set some vars.
    - MODULES: space separated list of modules to checked on sanity
    - INTEGRATION_MODULE: an integration module name to run in `ansible-test integration` command
    - CONTAINERS: space separated list of containers to run integration tests
    - FILTER_TAGS: tags to filter for in integration tests
    - LOG_LEVEL: log level to use during integration and unit tests (`vv` by default)

    Sample `.env` file: [sample.env](sample.env)

4. Build containers (you may skip this step, containers should be built on first launch):
    ```bash
    docker-compose build
    ```

## running tests

After your changes are made:

```bash
# run ansible-test sanity on python 3.5 for ${MODULES}
docker-compose run --rm sanity35
# run ansible-test sanity on python 2.7 for ${MODULES}
docker-compose run --rm sanity27
# run ansible-test integration for ${INTEGRATION_MODULE} in ${CONTAINERS}
docker-compose run --rm integration
# TODO: run ansible-test unit
docker-compose run --rm unit
```

You can have multiple env files for different modules / test suites when this [PR](https://github.com/docker/compose/pull/6535) is live:

```bash
# run ansible-test sanity on python 3.5 with modules from suite01.env
docker-compose --env-file suite01.env run --rm sanity35
```

## running some tests manually (sample)

1. Run an appropriate container:
    ```bash
    docker-compose run --rm manual35
    ```
2. Exec your tests
    ```bash
    # quick-test module
    ansible/hacking/test-module -m ./ansible/lib/ansible/modules/database/postgresql/postgresql_user.py
    # add custom deps
    pip install psycopg2-binary
    # exec module against some test playbook
    ansible-playbook sample.testmod.yml
    ```

    Sample playbook file: [sample.testmod.yml](sample.testmod.yml)
