import org.eclipse.emf.common.util.URI
import generator.VideoGenHelper
import generator.Generator
import java.io.File

class Main {
	def static void main(String[] args) {
		val video = new VideoGenHelper().loadVideoGenerator(URI.createURI("example2.videogen"))
		var generetor = new Generator();
		
		if(generetor.hasError(video)){
			return;
		}
		
		println("Step 1 : file is okay");
		//generetor.generate(video,"/home/aferey/Documents/IDM/Video/resultat1.mp4");
		generetor.generateGif(video);
		//util.addText("/home/aferey/Documents/IDM/Video/exemple1.mp4","ffmpeg",56);
		
	}
}