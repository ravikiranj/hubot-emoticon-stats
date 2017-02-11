# hubot-emoticon-stats

Emoticon Stats

See [`src/emoticon-stats.coffee`](src/emoticon-stats.coffee) for full documentation.

## Installation
* Install local redis server

* In hubot project repo, run:
`npm install hubot-emoticon-stats --save`

Then add **hubot-emoticon-stats** to your `external-scripts.json`:

```json
[
  "hubot-emoticon-stats"
]
```

## Sample Interaction

```
user1>> /emote top
hubot>> Lists top 10 emoticons
```
