# CheatChat API

API to store and retrieve card game hands (cards, player_id)

## Routes

All routes return a Json object

- GET `/`: Root route shows if Web API is running
- GET `api/v1/hand/`: returns all hand IDs
- GET `api/v1/hand/[ID]`: returns details about a single hand given an ID
- POST `api/v1/hand/`: creates a new hand

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