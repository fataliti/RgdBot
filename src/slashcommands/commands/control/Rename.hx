package slashcommands.commands.control;

import com.fataliti.types.InteractionData;
import com.fataliti.types.SlashCommand.SlashCommandArgumentType;

using Utils;

class Rename extends Slash {
    
    override function initialize() {
        slashCommand = {
            name: 'rn',
            description: 'сменить кому-то никтнейм',
            options: [
                {
                    name: 'user',
                    description: 'пользователь которому меняется ник',
                    required: true,
                    type: SlashCommandArgumentType.USER,
                },
                {
                    name: 'nickname',
                    description: 'новый никнейм',
                    required: true,
                    type: SlashCommandArgumentType.STRING
                }
            ]
        }
        slashCommand.registerSlashCommand();
    } 

    override function action(d:InteractionData) {
        var user = d.getInteractionValue('user');
        var nick = d.getInteractionValue('nickname');
        Rgd.bot.endpoints.editGuildMember(Rgd.rgdId, user, {nick: nick});
        d.resonseAnswer('произошла смена ника');
    }

}