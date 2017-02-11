# Description
#   Emoticon Stats
#
# Configuration:
#
# Commands:
#   /emote top - lists top 10 emoticons used
#   /emote bottom - lists bottom 10 emoticons sorted by count
#   /emote (emoticon) - lists count of a particular emoticon
#
# Notes:
#   Please install a redis server before installing/testing this plugin
#
# Author:
#   Ravikiran Janardhana <ravikiran.j.127@gmail.com>

emoticonRegex = /\([a-z0-9]+\)/g
topRegex = /^\/emote top$/i
bottomRegex = /^\/emote bottom$/i
emoteCountRegex = /^\/emote\s+(\([a-z0-9]+\))\s*$/i
allRegex = /^\/emote all$/i

class EmoticonCounts
    constructor: (@robot) ->
        @cache =
            emoticonCounts: {}

        @robot.brain.on 'loaded', =>
            @robot.brain.data.emoticonCounts = @robot.brain.data.emoticonCounts || {}
            @cache.emoticonCounts = @robot.brain.data.emoticonCounts

    initCounts: (counts) ->
        @cache.emoticonCounts = counts

    getEmoticonCount: (emoticon) ->
        @cache.emoticonCounts[emoticon] = @cache.emoticonCounts[emoticon] || 0
        return @cache.emoticonCounts[emoticon]

    saveEmoticonCount: (emoticon) ->
        @robot.brain.data.emoticonCounts[emoticon] = @cache.emoticonCounts[emoticon]
        @robot.brain.emit('save', @robot.brain.data)
        
    updateEmoticonCount: (emoticon) ->
        @cache.emoticonCounts[emoticon] = @getEmoticonCount(emoticon) + 1
        @saveEmoticonCount(emoticon)

        return @cache.emoticonCounts[emoticon]

    top: (n) ->
        tops = []
        for emoticon, count of @cache.emoticonCounts
            tops.push(emoticon: emoticon, count: count)

        return tops.sort((a,b) -> b.count - a.count).slice(0, n)

    bottom: (n) ->
        all = @top(@cache.emoticonCounts.length)
        return all.reverse().slice(0, n)

    all: () ->
        return @top(@cache.emoticonCounts.length)

module.exports = (robot) ->
    emoticonCounts = new EmoticonCounts(robot)

    robot.hear emoticonRegex, (msg) ->
        # Ignore hbot messages
        user = msg.message.user
        if user.mention_name == 'hbot'
            return

        # Ignore messages starting with '/emote'
        if msg.message.text.startsWith('/emote')
            return

        xmpp_jid = msg.message.user.reply_to

        for input in msg.match
            result = emoticonRegex.exec(input)
            # See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/exec#Description
            emoticonRegex.lastIndex = 0

            if result? and result[0]?
                emoticon = result[0].trim()
                value = emoticonCounts.updateEmoticonCount(emoticon)

    robot.hear topRegex, (msg) ->
        op = []
        n = 10
        top = emoticonCounts.top(n)
        for i in [0..top.length - 1]
            op.push("#{top[i].count} #{top[i].emoticon}")

        msg.send op.join("\n")

    robot.hear bottomRegex, (msg) ->
        op = []
        n = 10
        bottom = emoticonCounts.bottom(n)
        for i in [0..bottom.length - 1]
            op.push("#{bottom[i].count} #{bottom[i].emoticon}")

        msg.send op.join("\n")

    robot.hear emoteCountRegex, (msg) ->
        emoticon = msg.match[1]
        count = emoticonCounts.getEmoticonCount(emoticon)
        msg.send "#{emoticon} = #{count}"

    robot.hear allRegex, (msg) ->
        # Only respond if in Shire
        room_xmpp_jid = msg.message.user.reply_to
        if room_xmpp_jid != "1_shire@conf.btf.hipchat.com"
            return

        op = []
        all = emoticonCounts.all()
        for i in [0..all.length - 1]
            op.push("#{all[i].count} #{all[i].emoticon}")

        msg.send op.join("\n")
