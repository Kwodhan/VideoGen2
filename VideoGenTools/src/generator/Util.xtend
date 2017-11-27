package generator

import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.FileWriter
import java.io.IOException
import java.io.InputStreamReader
import java.util.List
import org.xtext.example.mydsl.videoGen.VideoDescription
import java.io.File
import java.nio.file.Files
import java.time.LocalDateTime
import java.nio.file.StandardCopyOption
import org.xtext.example.mydsl.videoGen.NegateFilter
import org.xtext.example.mydsl.videoGen.BlackWhiteFilter
import org.xtext.example.mydsl.videoGen.FlipFilter
import org.xtext.example.mydsl.videoGen.VideoText

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
ffmpeg -y -i «locationVideo» -vf drawtext=«bullshit» -c copy «locationOuptut»
'''
  	def private String ffmpegBlackAndWhite(String locationVideo,String locationOuptut) '''
ffmpeg -y -i «locationVideo» -vf hue=s=0 -c copy «locationOuptut»
'''
  	def private String ffmpegNegate(String locationVideo,String locationOuptut) '''
		ffmpeg -y -i «locationVideo» -vf lutrgb="r=negval:g=negval:b=negval" «locationOuptut»
	'''
  	def private String ffmpegFlip(String locationVideo,String typeflip,String locationOuptut) '''
		ffmpeg -y -i «locationVideo» -vf «typeflip» «locationOuptut»
	'''
  	def private String ffmpegPerdiod(String locationVideo,String locationOuptut,int minute,int second) '''
ffmpeg -y -ss 00:00:00 -i «locationVideo» -t 00:«minute»:«second» -c copy «locationOuptut»
'''

val private DIR_TEMP="/tmp/"
	/**
	 * 
	 */
	 def String filter(VideoDescription video){
	 	
	 	var locationOutput = DIR_TEMP +"f_"+Util.getID(video);
	 	var choise = video.filter;
	 	var command ="";
	 	if(choise instanceof NegateFilter){
	 		command = ffmpegBlackAndWhite(video.location,locationOutput)
	 	}else if(choise instanceof BlackWhiteFilter){
	 		command = ffmpegNegate(video.location,locationOutput)
	 	}else if(choise instanceof FlipFilter){
	 		switch ((choise as FlipFilter).orientation){
	 		case "h":  command = ffmpegFlip(video.location,"hflip",locationOutput)
	 		case "horizontal":  command = ffmpegFlip(video.location,"hflip",locationOutput)
	 		case "v":  command = ffmpegFlip(video.location,"vflip",locationOutput)
	 		case "vertical":  command = ffmpegFlip(video.location,"vflip",locationOutput)
	 		}
	 	}
	 	
	 	
	 	var p1 = Runtime.runtime.exec(command);
		p1.waitFor;
		printError(p1);
		return locationOutput;
	 }
	 /**
	 * 
	 */
	 def String duration(VideoDescription video){
	 	
	 	var locationOutput = DIR_TEMP +"d_"+Util.getID(video);
	 	var seconde = video.duration;
	 	var mins = seconde / 60;
    	var secs = seconde - mins * 60;
	 	var command1 = ffmpegPerdiod(video.location,locationOutput,mins,secs);
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
		printError(p1);
		return locationOutput;
	 }
	
	/**
	 * add a text in a center of the video 
	 */
	def String addText(VideoDescription video,VideoText videoconfig){
		var text = videoconfig.content;
		var position = videoconfig.position;
		var x = "x=(w-text_w)/2";
		var y = "y=(h-text_h)/2";
		var color ="white";
		var size = 32;
		switch (position){
	 		case "TOP":  {x="x=(w-text_w)/2";y="y=(h-text_h)/10";}
	 		case "CENTER":  {x="x=(w-text_w)/2";y="y=(h-text_h)/2";}					
	 		case "BOTTOM":  {x="x=(w-text_w)/2";y="y=(h-text_h)/1.1";}
	 		}
	 	if(videoconfig.color !==null){		
	 		color = videoconfig.color.toLowerCase 		
	 	}
	 	if(videoconfig.size !== 0){
	 		size = videoconfig.size;
	 	}

	 	var locationOutput = DIR_TEMP+"t_"+Util.getID(video);
		var command1 = ffmpegAddText(video.location,locationOutput,"fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf:text='"+text+"':fontcolor="+color+":fontsize="+size+":box=1:boxcolor=black@0.5:boxborderw=5:"+x+":"+y);
		println(command1)
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
		printError(p1);
		return locationOutput;
		
	}
	
	
	
	def String generateGif(VideoDescription video){
		var locationVideo = video.location;
		var locationOutput = locationVideo.substring(0,locationVideo.length() - 3)+"gif"
		var command1 = ffmpegPaletteGen(locationVideo);
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
		printError(p1);
		var command2 = ffmpegGenerateGif(locationVideo,locationOutput);
		var p2 = Runtime.runtime.exec(command2);
		p2.waitFor;
		printError(p2);
		return locationOutput;
	}
	/**
	 * 
	 */
	def String generateVignette(VideoDescription video){
		var locationVideo = video.location;
		var locationOutput = locationVideo.substring(0,locationVideo.length() - 3)+"png"
		var command1 = ffmpegGeneretedVignette(locationVideo,
			locationOutput);
		var p1 = Runtime.runtime.exec(command1);
		p1.waitFor;
		return locationOutput;
	}
	
	/**
	 * Longueur d'une video
	 */
	def Float getDuration(VideoDescription video){
		var locationVideo = video.location;
		var command1 = ffmpegComputeDuration(locationVideo);
		var p1 = Runtime.runtime.exec(command1)
		p1.waitFor
		return Float.parseFloat(printInput(p1));
	}
	
	def void generateVideo(List<VideoDescription> playlist, String outputPathFile){

		for(VideoDescription video : playlist){
			
			Dofilter(video);
		}
		writePlaylist(playlist);
		var command = ffmpegConcatenateCommand("output.ffconcat", outputPathFile);
		println(command);
		var p = Runtime.runtime.exec(command)
		p.waitFor
		printError(p);
	}
	
	def private VideoDescription Dofilter(VideoDescription video){
		println(video);
		var source = new File(video.location);
		var dest = new File(DIR_TEMP +Util.getID(video));
		Files.copy(source.toPath,dest.toPath,StandardCopyOption.REPLACE_EXISTING);
		video.location = dest.absolutePath;
		if(video.duration != 0){
			video.location = duration(video);
		}
		println(video.location);
		println(video.filter)
		if(video.filter !== null){
			video.location = filter(video);
		}
		
		if(video.text !== null){
			video.location = addText(video,video.text);
		}
		println(video.location);
		return video;
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
	
	def private static String getID(VideoDescription video){
		
		//var source = new File(video.location);
		return video.videoid+".mp4";
	} 
	
	def private void clean(List<VideoDescription> playlist){
		for(VideoDescription video : playlist){
			new File(DIR_TEMP+Util.getID(video)).delete
		}
		
	}
	
}
		