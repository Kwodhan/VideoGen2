package test

import static org.junit.Assert.*;
import generator.Generator
import generator.VideoGenHelper
import org.eclipse.emf.common.util.URI

class Test {
	
	@org.junit.Test
	public def void testFilter(){
		for(var i = 1 ;i<4;i++){
			val video = new VideoGenHelper().loadVideoGenerator(URI.createURI("videogenTestFile/example"+i+".videogen"))
			var generetor = new Generator();
			
			assertFalse(generetor.hasError(video));
		}
		
	}
	
}
