package;

import Section.SwagSection;
import EventsSystemSection.SwagEventsSystemSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagEventSystemChart =
{
	var notes:Array<SwagEventsSystemSection>;
}

class EventSystemChart
{
	public var notes:Array<SwagEventsSystemSection>;

	public function new(notes)
	{
		this.notes = notes;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagEventSystemChart
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagEventSystemChart
	{
		var swagShit:SwagEventSystemChart = cast Json.parse(rawJson).song;
		return swagShit;
	}
}
