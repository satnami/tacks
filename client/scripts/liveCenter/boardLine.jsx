/**
 * @jsx React.DOM
 */

var React    = require('react');
var _        = require('lodash');
var moment   = require('moment');
var util     = require('../util');
var Messages = require('../messages');
var PlayerWithAvatar = require('./playerWithAvatar');

var BoardLine = React.createClass({

  getPlayers: function(playerStates) {
    return _.map(playerStates, p => {
      return <PlayerWithAvatar player={p.player} />;
    });
  },

  getCountdown: function(millis) {
    if (millis) {
      if (millis > 0) return Messages('liveCenter.startingIn', Math.ceil(millis / 1000));
      else return Messages("liveCenter.startedSince", util.timer(Math.abs(millis)));
    } else {
      return "";
    }
  },

  render: function() {
    var s = this.props.raceStatus;
    var players = this.getPlayers(s.playerStates);
    var millis = s.startTime ? (s.startTime - this.props.now) : null;

    return (
      <tr>
        <td className="generator">
          { Messages('generators.' + s.race.generator + '.name') }
        </td>
        <td className="master"><PlayerWithAvatar player={ s.master } /></td>
        <td className="players">
          { players }
        </td>
        <td className="countdown">{ this.getCountdown(millis) }</td>
        <td>
          <a href={ "/play/" + s.race._id } target="_blank" className="btn btn-block btn-warning">
            { Messages("liveCenter.join") }
          </a>
        </td>
      </tr>
    );
  }

});

module.exports = BoardLine;