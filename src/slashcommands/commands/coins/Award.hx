package slashcommands.commands.coins;

import com.fataliti.types.SlashCommand.CommandPermissionType;
import com.raidandfade.haxicord.types.Snowflake;
import com.fataliti.types.SlashResponse;
import com.fataliti.types.InteractionData;
import com.fataliti.types.SlashCommand.SlashCommandPermission;
import com.fataliti.types.SlashCommand.SlashCommandArgumentType;

using Utils;

class Award extends Slash {

    override function initialize() {
        slashCommand = {
            name: "award",
            description: "Выдать кому-то монет",
            default_permission: false,
            options: [
                {
                    name: "user",
                    description: "Кому выдать",
                    type: SlashCommandArgumentType.USER,
                    required: true
                },
                {
                    name: "amount",
                    description: "Сколько выдать",
                    type: SlashCommandArgumentType.INTEGER,
                    required: true
                },
            ]
        }


        Utills.registerSlashCommand(slashCommand, (d, e) -> {
            trace(e);
            trace(d);
            if (e == null) {

                var permission:SlashCommandPermission = {
                    id: '504624668787998721',
                    type: CommandPermissionType.ROLE,
                    permission: true
                }

                Rgd.bot.endpoints.guildCommandEditPermission({permissions: [permission]}, Rgd.appId, Rgd.rgdId, d.id);
            }
        });
    }

    override function action(d:InteractionData) {

        var user = d.getInteractionValue('user');
        var amount = d.getInteractionValue('amount');
        Rgd.db.request('UPDATE users SET coins = coins + $amount WHERE userId = "${user}"');

        var r:SlashResponse = {
            type: InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
            data: {
                content: 'Выдано <@${user}> `$amount` <:rgd_coin_rgd:745172019619823657>'
            }
        }
        d.response(r);
    }

}