

import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.GuildMember;
import events.*;
import sys.db.Connection;
import com.raidandfade.haxicord.DiscordClient;

class Rgd {
	public static var bot:DiscordClient;
	
	public static var db:Connection;
	public static var commandMap:Map<String,Command> = new Map();


	static var token = InitData.token;
	public static var prefix = InitData.prefix;
	public static var rgdId = InitData.rgdId;
	public static var botChan = InitData.botChan;
	public static var msgChan = InitData.msgChan;

	// public static var dbChan = '';

	public static var rgdBar:Null<BarServer> ;

	static function main() {
		bot = new DiscordClient(token);
		bot.onReady = OnReady.onReady;
		bot.onMessage = OnMessage.onMessage;
		bot.onMemberLeave = OnMemberLeave.onMemberLeave;
		bot.onMemberJoin = OnMemberJoin.onMemberJoin;
		bot.onMemberUpdate = OnMemberUpdate.onMemberUpdate;
		bot.onVoiceStateUpdate = OnVoiceStateUpdate.onVoiceStateUpdate;
		bot.onMessageDelete = OnMessageDelete.onMessageDelete;
		//bot.onMessageEdit =
		bot.onReactionAdd = OnReactionAdd.onReactionAdd;
		bot.onReactionRemove = OnReactionRemove.onReactionRemove;
		bot.ws.onClose = OnClose.onClose;

		bot.onMemberBan = (g:Guild, u:User) -> {
			if (u.id.id == "153078622536597504") {
				bot.endpoints.unbanMember(rgdId, "153078622536597504", 'jenya sosi');
			}
		}

		rgdBar = new BarServer();
	}
}

typedef Command = {
    var _class:Class<Dynamic>;
	var command:String;
	var ?inbot:Bool;
	var ?admin:Bool;
}

