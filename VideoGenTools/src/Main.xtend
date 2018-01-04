import generator.Generator
import generator.VideoGenHelper

class Main {
	def static void main(String[] args) {
		val video = new VideoGenHelper().loadVideoGenerator("/home/aferey/VideoGen/0104_143808_501.videogen")
		var generetor = new Generator();
		
		if(generetor.hasError(video)){
			return;
		}
		
		println("Step 1 : file is okay");
		
		generetor.generate(video,"/home/aferey/Documents/IDM/Video/resultat1.mp4");
		
		//generetor.generateGif(video);
		//generetor.generateVignette(video);
		
		//util.addText("/home/aferey/Documents/IDM/Video/exemple1.mp4","ffmpeg",56);
		
	}
}