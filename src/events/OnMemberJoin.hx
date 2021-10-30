package events;


import haxe.Timer;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.Guild;

class OnMemberJoin {
    public static function onMemberJoin(g:Guild, m:GuildMember) {
        if (g.id.id != Rgd.rgdId) return;

        var roles = Rgd.db.request('SELECT roleId FROM usersRole WHERE userId = "${m.user.id.id}"').results();
        var returner = new Timer(1000);
        returner.run = () -> {
            var role = roles.pop();
            if (role == null) {
                returner.stop();
            } else {
                m.addRole(role.roleId);
            }
        }

        var get = Rgd.db.request('SELECT leave FROM users WHERE userId = "${m.user.id.id}"').results();

        if (get.length > 0) {
            var exist = get.first().leave;
            Rgd.bot.sendMessage(Rgd.msgChan, {content: StringTools.replace(repls[Std.random(repls.length)], "%", '**${m.user.username}**')+'|| $exist раз ||'});
        } else {
            Rgd.bot.sendMessage(Rgd.msgChan, {content: '***'+StringTools.replace(first[Std.random(first.length)], "%", '<@${m.user.id.id}>') + '***' });
        }

        Rgd.db.request('INSERT OR IGNORE INTO users(userId, first, here) VALUES("${m.user.id.id}", "${m.joined_at.toString()}", 1)');
        Rgd.db.request('UPDATE users SET here = 1 WHERE userId = "${m.user.id.id}"');
    }


    static var repls = [
        "Никто не просил, а % вернулся",
        "% вернулся, открывайте форточку",
        "Становится душно, % снова здесь",
        "Стокгольмский синдром, % знает о нём не по наслышке",
        "А ты разве не упиздел на конфу.гд %",
        "% хочет второй шанс",
        "Уровень дерьма снова повысился, % здесь",
        "% вернулся в RGD",
        "блудный % вернулся",
        "Душная тревога, % зашел назад",
        "% сколько лет, сколько зим",
        "% вернулся с завода",
        "%, а где ты был?",
        "Добро пожаловать, %, снова"
    ];


    static var first = [
        "% решил вкатиться в геймдев",
        "% обязательно вкатится",
        "% встал на путь",
        "% впервые зашел на ргд",
        "свежеприбывший %, поприветствуем"
    ];
}