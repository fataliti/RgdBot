package slashcommands.commands;

import events.OnClose;
import Utils.Utills;

import com.fataliti.types.SlashCommand;
import com.fataliti.types.SlashResponse;
import com.fataliti.types.InteractionData;

class CommandKill extends Slash {
    
    public override function initialize() {
        slashCommand = {
            name: "kill",
            description: "Перезапустить бота",
        }
        Rgd.bot.endpoints.registerGuildCommand(slashCommand, Rgd.appId, Rgd.rgdId);
    }

    

    public override function  action(d:InteractionData):Void {
        if (Utills.isBossUser(d.member.user.id)) {  
            var respsonse:SlashResponse = {
                type: InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
                data: {
                    content: "Рестарт бота",
                }
            }
            Rgd.bot.endpoints.commandResponse(respsonse, d.id, d.token);
            OnClose.onClose(0);
        }
    }

}