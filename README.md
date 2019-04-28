# Vitae API

API to store and retrieve card project notes (text, player_id)

## Routes

All routes return a Json object

- GET `/`: Root route shows if Web API is running
- GET `api/v1/note/`: returns all note IDs
- GET `api/v1/note/[ID]`: returns details about a single note given an ID
- POST `api/v1/note/`: creates a new note

## Install

Install this API by cloning the and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Execute

Run this API using:

```shell
rackup
```