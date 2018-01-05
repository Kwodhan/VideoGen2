import generator.Generator
import generator.VideoGenHelper

class Main {
	def static void main(String[] args) {
		val video = new VideoGenHelper().loadVideoGenerator("exemple.videogen")
		var generetor = new Generator();
		
		if(generetor.hasError(video)){
			return;
		}
		
		println("Step 1 : file is okay");
		generetor.generateVignette(video);
		//generetor.generateGif(video,"/home/aferey/Documents/IDM/Video/resultat1.gif");
		generetor.generate(video,"/home/aferey/Documents/IDM/Video/resultat1.mp4");
		
		
		
		//util.addText("/home/aferey/Documents/IDM/Video/exemple1.mp4","ffmpeg",56);
		
	}
}