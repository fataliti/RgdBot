import com.raidandfade.haxicord.types.Message;


class Utills {
    public static function answer(m:Message, text:String) {
        m.reply({embed: {description: text}});
    }   
}