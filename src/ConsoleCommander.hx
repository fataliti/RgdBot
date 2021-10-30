import haxe.Timer;
import sys.thread.Thread;

import events.OnClose;

class ConsoleCommander {

	public function new() {
		var thread = Thread.create(awaitInput); 
	}


	public function awaitInput() {
		while (true) {
			var input = Sys.stdin();
			inputParse(input.readLine());
		}
	}

	public function inputParse(input:String) {
		

        switch(input) {
            case 'clear':
                Rgd.bot.endpoints.getGuildCommands(Rgd.appId, Rgd.rgdId, (d, e) -> {
                    if (e == null) {
                        while (d.length > 0) {
                            var func = d.shift();
                            Rgd.bot.endpoints.deleteGuildCommand(Rgd.appId, Rgd.rgdId, func.id);
                        }
                    }
                });

            case 'kill':
                OnClose.onClose(0);  
        }

	}

}


