hubot-leaderboard
=================

Hubot plugin to keep track of leaderboards
Useful for keeping track of who has won the most King of Tokyo or Mario Kart games in the office.

## Installation

### Update the files to include the hubot-leaderboard module:

#### package.json
    ...
    "dependencies": {
      ...
      "hubot-leaderboard": ">= 0.3.0"
      ...
    },
    ...

#### external-scripts.json
    [...,"hubot-leaderboard"]

Run `npm install` to install hubot-leaderboard and dependencies.

Commands
-----
```
hubot <user> climbs <event> leaderboard - Add a victory for the user
hubot set <event> leaderboard <user> <score> - Set the score for a user
hubot show <event> leaderboard - Returns the event leaderboard
hubot reset <event> leaderboard - Clears the event leaderboard
hubot list leaderboards - Returns a list of leaderboards
```
