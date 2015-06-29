# hubot-country-time

Hubot script to show time in a specified country

See [`src/country-time.coffee`](src/country-time.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-country-time --save`

Then add **hubot-country-time** to your `external-scripts.json`:

```json
[
  "hubot-country-time"
]
```

## Sample Interaction

```
user1>> hubot daytime
hubot>> It's daytime in: Argentina, Canada, Colombia, Mexico, New Zealand, United States, Caribbean, and Latin America

user1>> hubot what time is it in Switzerland
hubot>> It's 10:14 pm in Switzerland right now.

user1>> hubot nighttime in de
hubot>> It's 10:16 pm in Germany right now. :crescent_moon:
```
