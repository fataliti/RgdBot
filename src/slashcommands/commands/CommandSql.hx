package slashcommands.commands;

import Utils.Utills;

import com.fataliti.types.SlashCommand;
import com.fataliti.types.SlashResponse;
import com.fataliti.types.InteractionData;

class CommandSql extends Slash {
    
    public override function initialize() {
        slashCommand = {
            name: "sql",
            description: "Сделать запрос к SQL базе бота",
            options: [
                {name: 'запрос', 
                description: 'строка запроса', 
                type: SlashCommandArgumentType.STRING, 
                required: true}
            ],
        }

        Rgd.bot.endpoints.registerGuildCommand(slashCommand, Rgd.appId, Rgd.rgdId);
    }

    

    public override function  action(d:InteractionData):Void {
        if (Utills.isBossUser(d.member.user.id)) {
            var get = Rgd.db.request(Utills.getInteractionValue(d, 'запрос'));

            var response:SlashResponse = {
                type: CHANNEL_MESSAGE_WITH_SOURCE,
                data: {
                    embeds: [
                        {
                            description:  get.results().toString()
                        }
                    ]
                }
            }
            Rgd.bot.endpoints.commandResponse(response, d.id, d.token);
        }
    }

}