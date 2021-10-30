
import events.*;
import sys.db.Connection;

import com.raidandfade.haxicord.DiscordClient;
import com.fataliti.types.InteractionData;

class Rgd {
	public static var bot:DiscordClient;
	
	public static var db:Connection;
	public static var commandMap:Map<String,Command> = new Map();
	public static var slashCommands:Map<String, (d:InteractionData) -> Void > = new Map();

	static var token = InitData.token;
	public static var prefix = InitData.prefix;
	public static var rgdId = InitData.rgdId;
	public static var botChan = InitData.botChan;
	public static var msgChan = InitData.msgChan;
	public static var appId   = InitData.applicationId;

	// public static var dbChan = '';

	public static var rgdBar:Null<BarServer>;
	public static var rgdWiki:RgdWikiTcpServer;


	public static var consoleCommander:ConsoleCommander;

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
		bot.onMessageEdit = OnMessageEdit.onMessageEdit;
		bot.onMemberBan = OnMemberBan.onMemberBan;
		bot.onInteraction = OnInteraction.onInteraction;
		bot.ws.onClose = OnClose.onClose;

		rgdWiki = new RgdWikiTcpServer();
		//rgdBar = new BarServer();

		consoleCommander = new ConsoleCommander();
	}
}


typedef Command = {
    var _class:Class<Dynamic>;
	var command:String;
	var ?inbot:Bool;
	var ?admin:Bool;
}

