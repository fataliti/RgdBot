package events;

import haxe.Timer;
import commands.RandomEvent;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.Guild;

class OnMemberUpdate {
    public static function onMemberUpdate(g:Guild, m:GuildMember) {
        if (g.id.id != Rgd.rgdId) return;


        if (RandomEvent.renamedUser.exists(m.user.id.id)) {
            if (m.displayName != RandomEvent.renamedUser.get(m.user.id.id)) {
                var _randName = RandomEvent.renamedUser.get(m.user.id.id);
                var renameTimer = new Timer(1000*3);
                renameTimer.run = () -> {
                    m.changeNickname(_randName, (newName, err) -> {
                        if (err == null) {
                            renameTimer.stop();
                        }
                    });
                }
            }
        } else {
            var isRenamed = false;

            var getLastRenames = Rgd.db.request('SELECT id, userId, nick FROM usersNick WHERE userId = "${m.user.id.id}" ORDER BY id DESC LIMIT 1').results();
            if (getLastRenames.length > 0) {
                if (getLastRenames.first().nick != m.displayName) {
                    isRenamed = true;
                }
            } else {
                isRenamed = true;
            }

            if (isRenamed) {
                Rgd.db.request('INSERT INTO usersNick(userId, nick) VALUES("${m.user.id.id}", "${m.displayName}")');
            }
        }
        

        if (RandomEvent.mod15Arr.contains(m.user.id.id)) {
            return;
        }
        Rgd.db.request('DELETE FROM usersRole WHERE userId = "${m.user.id.id}"');
        for (role in m.roles) {
            Rgd.db.request('INSERT OR IGNORE INTO usersRole(userId, roleId) VALUES("${m.user.id.id}", "$role")');
        }
    }


    static var phrases = [
        "% решил смыть с себя позор и сменил имя на @",
        "% подумал, что имя @ ему идёт больше",
        "% эволюционировал в @",
        "% больше нет. Его место занял @",
        "% попросил называть его @",
        "% стесняется своего имени, обращайтесь к нему @",
        "% продал никнейм дьяволу. Теперь он всего лишь @",
        "Наступило Кроволуние! % превратился в @",
        "Внимание! У % произошла смена никнейма на @",
        "Когда Бог раздавал никнеймы, к нему пришел жадный % и попросил ещё и @.",
        "% сменил никнейм на @. Ну сменил и сменил.",
        "Забудьте %! Теперь он - @!",
        "% пожелал таинственности и назвался @",
        "Кто в ночи на бой спешит, побеждая зло? Точно не %. Он всего лишь переименовался в @",
        "Однажды ты спросишь меня, что я больше люблю: % или @? Ты уйдёшь, так и не узнав, что это один и тот же человек.",
        "Путин приказал переименовать % в @.",
        "% сменил никнейм на @, а он ему как раз.",
        "Заходят в бар как-то % и @, а бармен им говорит: -Ты задолбал ник менять, %.",
        "Пришли как-то % и @ получать зарплату. Но в бухгалтерии всё записано, и ему ничего не дали.",
        "Видишь %? И я не вижу. А он теперь есть @.",
        "% поверил, что если сменит имя на @, то над ним будут меньше смеяться. Ну-ну."
    ];

}