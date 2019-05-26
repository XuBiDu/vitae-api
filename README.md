# Vitae API

API to store and retrieve confidential academic sheet notes and CVs

## Routes

All routes return Json

- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST  `api/v1/accounts`: Create a new sheet
- GET  `api/v1/sheets/[sheet_id]/notes/[doc_id]`: Get a note
- GET  `api/v1/sheets/[sheet_id]/notes`: Get list of notes for sheet
- POST `api/v1/sheets/[sheet_id]/notes`: Upload note for a sheet
- GET  `api/v1/sheets/[sheet_id]`: Get information about a sheet
- GET  `api/v1/sheets`: Get list of all sheets
- POST `api/v1/sheets`: Create new sheet

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this sheet:

```bash
rake db:seed
```

## Execute

Launch the API using:

```shell
rackup
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release?
```