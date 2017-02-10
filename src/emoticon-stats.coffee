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

emoticonRegex = /(\([a-z0-9]+\))/gi

module.exports = (robot) ->
    robot.hear emoticonRegex, (res) ->
        user = msg.message.user
        if user.mention_name == 'hbot'
            return

        xmpp_jid = msg.message.user.reply_to

        for input in msg.match
            result = emoticonRegex.exec(input)
            # See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/exec#Description
            emoticonRegex.lastIndex = 0

            if result? and result[1]?
                emoticon = result[1]
                robot.logger.info "Saw emoticon = #{emoticon}"
