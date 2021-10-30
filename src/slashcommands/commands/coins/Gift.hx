package slashcommands.commands.coins;

import com.fataliti.types.InteractionData;

using Utils;

class Gift extends Slash{
    
    static var giftCd:Array<String> = [];

    override function initialize() {
        slashCommand = {
            name: 'gift',
            description: 'Получить подарок в виде монет от бота'
        }

        slashCommand.registerSlashCommand();
    }

    override function action(d:InteractionData) {
        
        if (giftCd.contains(d.member.user.id)) {
            d.resonseAnswer("Попробуй чуть позже");
            return;
        }

        var random = Std.random(16) + 5;

        Rgd.db.request('UPDATE users SET coins = coins + $random WHERE userId = "${d.member.user.id}"');
        d.resonseAnswer('<@${d.member.user.id}> получил из подарка `$random` монет');
        giftCd.push(d.member.user.id);

    }

    

}