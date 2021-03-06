# Description:
#   Announce Scout notifications to a slack room.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Notes:
#   To use:
#     Setup http://hostname/hubot/scoutapp-slack/%23ROOMNAME as
#     your notification webhook in scoutapp.com.
#

module.exports = (robot) ->
  robot.router.post '/hubot/scoutapp-slack/:room', (req, res) ->
    room = req.params.room

    data = JSON.parse req.body.payload

    # Example post data
    #
    # {
    #   "id": 999999,
    #   "time": "2012-03-05T15:36:51Z",
    #   "server_name": "Blade",
    #   "server_hostname": "blade",
    #   "lifecycle": "start", // can be [start|end]
    #   "title": "Last minute met or exceeded 3.00 , increasing to 3.50 at 01:06AM",
    #   "plugin_name": "Load Average",
    #   "metric_name": "last_minute",
    #   "metric_value": 3.5,
    #   "severity": "warning", // warning = normal threshold, critical = SMS threshold
    #   "url": "https://scoutapp.com/a/999999",
    #   "sparkline_url":"https://scoutapp.com/alert_sparkline.png"
    # }

    isAlert = data.lifecycle is "start"
    color   = if isAlert then "danger" else "good"
    prefix  = if isAlert then "Alert" else "Back to Normal"
    emoji   = if isAlert then ":warning:" else ":thumbsup:"
    fields  = []

    fields = [
        title: prefix
        value: data.url
        short: true
      ,
        title: "Server Name"
        value: data.server_name
        short: true
      ,
        title: data.plugin_name
        value: data.title
        short: false
    ]

    fallback = "#{prefix} : #{data.plugin_name} : #{data.title}"

    robot.emit 'slack-attachment',
      message:
        room:       room
        username:   'scout'
        icon_emoji: emoji
      content:
        text:     ''
        color:    color
        pretext:  ''
        fallback: fallback
        fields:   fields

    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
