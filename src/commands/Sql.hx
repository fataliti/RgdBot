package commands;

import com.fataliti.types.SlashCommand.SlashCommandArgumentType;
import Utils.Utills;
import events.OnReady;
import events.OnClose;
import com.raidandfade.haxicord.types.Message;


import com.fataliti.types.InteractionData;
import com.fataliti.types.SlashResponse;

class Sql {
    
    @command(['sql'], 'реквест к базе данных')
    public static function sql(m:Message, w:Array<String>) {
        if (m.author.id.id != '371690693233737740') return;
        var get = Rgd.db.request(w.join(' '));

        if (get.length == 0) return;

        m.reply({embed: {description: get.results().toString()}}, (msg, err) -> {
            if (err != null) {
                m.reply({content: 'err'});
            }
        });
    }

    @command(['kill'], 'вырубить бота')
    public static function kill(m:Message, w:Array<String>) {
        if (m.author.id.id != '371690693233737740') return;
        command_kill();
    }


    @slash("kill", "Команда выключения бота", [])
    public static function slashKill(d:InteractionData) {
        if (Utills.isBossUser(d.member.user.id)) {  
            var respsonse:SlashResponse = {
                type: InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
                data: {
                    content: "Рестарт бота",
                }
            }
            Rgd.bot.endpoints.commandResponse(respsonse, d.id, d.token);
            command_kill();
        }
    }

    @command(['esus'], 'исусья команда')
    public static function jesus(m:Message, w:Array<String>) {
        if (m.author.id.id != '209387687948320769') return; 
        Rgd.db.request('UPDATE users SET rep = 888 WHERE userId = "209387687948320769"');
        RandomEvent.blessChannel(m.channel_id.id);
        m.reply({embed: {image: {url: "https://cdn.discordapp.com/attachments/697115584986349608/747495897465618442/unknown.png"}, title: "Есус благославляет этот канал"}});
		m.delete();
    }

    

    static function command_kill() {
        trace("killing");
        OnClose.onClose(0);
    }

}