import org.eclipse.emf.common.util.URI

class Main {
	def static void main(String[] args) {
		val video = new VideoGenHelper().loadVideoGenerator(URI.createURI("example2.videogen"))
		var generetor = new Generator();
		var util = new Util();
		if(generetor.hasError(video)){
			return;
		}
		
		println("Step 1 : file is okay");
		
		//generetor.generateGif(video);
		util.addText("/home/aferey/Documents/IDM/Video/exemple1.mp4","ffmpeg",56);
		
	}
}