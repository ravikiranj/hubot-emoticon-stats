# Description
#   Emoticon Stats
#
# Configuration:
#
# Commands:
#   (emoticon) - listens to emoticons to record stats
#
# Notes:
#
# Author:
#   Ravikiran Janardhana <ravikiran.j.127@gmail.com>

emoticonRegex = /(^|\s)\([a-z0-9]+\)(\s|$)/gi
topRegex = /^\/emote top$/i
bottomRegex = /^\/emote bottom$/i
emoteCountRegex = /^\/emote\s+(\([a-z0-9]+\))\s*$/i

class EmoticonCounts
    constructor: (@robot) ->
        @cache =
            emoticonCounts: {}

        @robot.brain.on 'loaded', ->
            @robot.brain.data.emoticonCounts = @robot.brain.data.emoticonCounts || {}
            @cache.emoticonCounts = @robot.brain.data.emoticonCounts

    initCounts: (counts) ->
        @cache.emoticonCounts = counts

    getEmoticonCount: (emoticon) ->
        @cache.emoticonCounts[emoticon] = @cache.emoticonCounts[emoticon] || 0
        return @cache.emoticonCounts[emoticon]

    saveEmoticonCount: (emoticon) ->
        @robot.brain.data.emoticonCounts[emoticon] = @cache.emoticonCounts[emoticon]
        @robot.brain.emit("save", @robot.brain.data)
        
    updateEmoticonCount: (emoticon) ->
        @cache.emoticonCounts[emoticon] = @getEmoticonCount(emoticon) + 1
        @saveEmoticonCount(emoticon)

        return @cache.emoticonCounts[emoticon]

    top: (n) ->
        tops = []
        for emoticon, count of @cache.emoticonCounts
            tops.push(emoticon: emoticon, count: count)

        return tops.sort((a,b) -> b.score - a.score).slice(0, n)

    bottom: (n) ->
        bottoms = []
        for emoticon, count of @cache.emoticonCounts
            bottoms.push(emoticon: emoticon, count: count)

        return bottoms.sort((a,b) -> a.score - b.score).slice(0, n)

module.exports = (robot) ->
    emoticonCounts = new EmoticonCounts(robot)

    robot.hear emoticonRegex, (msg) ->
        # Ignore hbot messages
        user = msg.message.user
        if user.mention_name == 'hbot'
            return

        # Ignore messages starting with "/emote"
        if msg.message.text.startsWith("/emote")
            return

        xmpp_jid = msg.message.user.reply_to

        for input in msg.match
            result = emoticonRegex.exec(input)
            # See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/exec#Description
            emoticonRegex.lastIndex = 0

            if result? and result[0]?
                emoticon = result[0].trim()
                value = emoticonCounts.updateEmoticonCount(emoticon)
                @robot.logger.info "Updated #{emoticon} count to #{value}"

    robot.hear topRegex, (msg) ->
        op = []
        n = 10
        tops = emoticonCounts.top(n)
        for i in [0..tops.length - 1]
            op.push("#{i+1}: #{tops[i].emoticon} : #{tops[i].count}")

        msg.send op.join("\n")

    robot.hear bottomRegex, (msg) ->
        op = []
        n = 10
        bottom = emoticonCounts.bottom(n)
        for i in [0..bottom.length - 1]
            op.push("#{i+1}: #{bottom[i].emoticon} : #{bottom[i].count}")

        msg.send op.join("\n")

    robot.hear emoteCountRegex, (msg) ->
        emoticon = msg.match[1]
        count = emoticonCounts.getEmoticonCount()
        msg.send "#{emoticon} = #{count}"
