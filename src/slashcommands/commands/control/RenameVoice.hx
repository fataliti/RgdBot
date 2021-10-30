package slashcommands.commands.control;

import com.fataliti.types.InteractionData;
import com.fataliti.types.SlashCommand.SlashCommandArgumentType;
using Utils;

class RenameVoice extends Slash {

    override function initialize() {
        slashCommand = {
            name: 'rnvoice',
            description: 'сменить голосовому каналу название',
            options: [
                {
                    name: 'channel',
                    description: 'пользователь которому меняется ник',
                    required: true,
                    type: SlashCommandArgumentType.CHANNEL,
                },
                {
                    name: 'name',
                    description: 'новое название',
                    required: true,
                    type: SlashCommandArgumentType.STRING
                }
            ]
        }

        slashCommand.registerSlashCommand();
    } 


    override function action(d:InteractionData) {

        var ch = d.getInteractionValue('channel');
        var name    = d.getInteractionValue('name');

        if (!Rgd.bot.getGuildUnsafe(Rgd.rgdId).voiceChannels.exists(ch)) {
            d.resonseAnswer('или такого канала нет или это не войс канал');
            return;
        }
        Rgd.bot.getGuildUnsafe(Rgd.rgdId).voiceChannels[ch].editChannel({name: name});
        d.resonseAnswer('произошло переименование войса');
    }

}