import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.FileWriter
import java.io.IOException
import java.io.InputStreamReader
import java.util.List
import org.xtext.example.mydsl.videoGen.VideoDescription
import java.io.File

class Util {
	
	
	def private String ffmpegConcatenateCommand(String mpegPlaylistFile, String outputPath) '''
ffmpeg -y -f  concat -safe 0 -i «mpegPlaylistFile» -c copy  «outputPath»
'''

	def private String ffmpegComputeDuration(String locationVideo) '''
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 «locationVideo»
'''
	def private String ffmpegGeneretedVignette(String locationVideo, String locationImage) '''
ffmpeg -y -i «locationVideo» -r 1 -t 00:00:01 -ss 00:00:11 -f image2 «locationImage»
'''
	def private String ffmpegPaletteGen(String locationVideo) '''
ffmpeg -y -ss 1 -t 3 -i «locationVideo» -vf fps=10,scale=320:-1:flags=lanczos,palettegen palette.png
'''
	def private String ffmpegGenerateGif(String locationVideo, String locationOuptut) '''
ffmpeg -y -ss 1 -t 3 -i «locationVideo» -i palette.png -filter_complex fps=10,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse «locationOuptut»
'''
	def private String ffmpegAddText(String locationVideo,String locationOuptut,String bullshit) '''
ffmpeg -y -i «locationVideo» -vf drawtext=«bullshit» -codec:a copy «locationOuptut»
'''
  	def private String ffmpegBlackAndWhite(String locationVideo,String locationOuptut) '''
ffmpeg -y -i «locationVideo» -vf hue=s=0 -c:a copy «locationOuptut»
'''
  	def private String ffmpegNegate(String locationVideo,String locationOuptut) '''
 ffmpeg -y -i «locationVideo» -vf lutrgb="r=negval:g=negval:b=negval" «locationOuptut»
'''
  	def private String ffmpegHFlip(String locationVideo,String locationOuptut) '''
 ffmpeg -y -i «locationVideo» -vf "hflip" «locationOuptut»
'''
  	def private String ffmpegVFlip(String locationVideo,String locationOuptut) '''
 ffmpeg -y -i «locationVideo» -vf "vflip" «locationOuptut»
'''
  	def private String ffmpegPerdiod(String locationVideo,String locationOuptut,int minute) '''
ffmpeg -y -ss 00:00:00 -i «locationVideo» -t «minute» -c:a copy «locationOuptut»
'''

	/**
	 * 
	 */
	 def void filter(String locationVideo,String choise){
	 	var command ="";
	 	switch (choise){
	 		case "b&w":  command = ffmpegBlackAndWhite(locationVideo,"")
	 		case "negate":  command = ffmpegNegate(locationVideo,"")
	 		case "h":  command = ffmpegHFlip(locationVideo,"")
	 		case "horizontal":  command = ffmpegHFlip(locationVideo,"")
	 		case "v":  command = ffmpegVFlip(locationVideo,"")
	 		case "vertical":  command = ffmpegVFlip(locationVideo,"")
	 		default : return
	 	}
	 	
	 	var p1 = Runtime.runtime.exec(command);
		p1.waitFor;
		printError(p1);
	 }
	 /**
	 * 
	 */
	 def void duration(String locationVideo,int minute){
	 	var command1 = ffmpegPerdiod(locationVideo,"",minute);
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
		printError(p1);
	 }
	
	/**
	 * add a text in a center of the video 
	 */
	def void addText(String locationVideo,String text,int taille){
		var file = new File(locationVideo);
		
		var command1 = ffmpegAddText(locationVideo,"","fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf:text='"+text+"':fontcolor=white:fontsize="+taille+":box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2");
		println(command1)
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
		printError(p1);
		
	}
	
	
	
	def void generateGif(String locationVideo){
		var command1 = ffmpegPaletteGen(locationVideo);
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
		printError(p1);
		var command2 = ffmpegGenerateGif(locationVideo,locationVideo.substring(0,locationVideo.length() - 3)+"gif");
		var p2 = Runtime.runtime.exec(command2);
		p2.waitFor;
		printError(p2);
	}
	/**
	 * 
	 */
	def void generateVignette(String locationVideo){
		var command1 = ffmpegGeneretedVignette(locationVideo,
			locationVideo.substring(0,locationVideo.length() - 3)+"png");
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
	}
	
	/**
	 * Longueur d'une video
	 */
	def Float duration(String locationVideo){
		var command1 = ffmpegComputeDuration(locationVideo);
		var p1 = Runtime.runtime.exec(command1)
		p1.waitFor
		return Float.parseFloat(printInput(p1));
	}
	
	def void generateVideo(List<VideoDescription> playlist, String outputPathFile){
		writePlaylist(playlist);
		var command = ffmpegConcatenateCommand("output.ffconcat", outputPathFile);
		println(command);
		var p = Runtime.runtime.exec(command)
		p.waitFor
		printError(p);
	}

	/**
	 * Print la sortie standard
	 */
	def private String printInput(Process p) {
		var output = new BufferedReader(new InputStreamReader(p.getInputStream()));
		var ligne = "";
		var string = "";
		while ((ligne = output.readLine()) !== null) {
			string += ligne;

		}
		return string;
	}

	/**
	 * Print la sortie erreur
	 */
	def private String printError(Process p) {
		var output = new BufferedReader(new InputStreamReader(p.getErrorStream()));
		var ligne = "";
		var string = "";
		while ((ligne = output.readLine()) !== null) {
			string += ligne;
			System.out.println(ligne);
		}
		return string;
	}
	
	/**
	 * ecrit une playlist
	 */
	def private String writePlaylist(List<VideoDescription> playlist) throws IOException {
		var string = "";
		val writer = new BufferedWriter(new FileWriter("output.ffconcat"));
		
		for (VideoDescription video : playlist) {
			println(video.location);
			string += "file '" + video.location + "'\n";
			writer.write("file '" + video.location + "'\n");
		}

		writer.close();

		return string;
	}
	
}