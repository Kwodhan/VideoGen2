package test

import generator.Generator
import generator.VideoGenHelper
import java.util.ArrayList

import static org.junit.Assert.*

class Test {
	
	var files = new ArrayList<String>;
	var badfiles = new ArrayList<String>;
	@org.junit.Test
	public def void testFilter(){
		files.add("videogenTestFile/example1.videogen");
		files.add("videogenTestFile/example2.videogen");
		files.add("videogenTestFile/example3.videogen");
		
		badfiles.add("videogenTestFile/example4Bad.videogen");
		badfiles.add("videogenTestFile/example5Bad.videogen");
		badfiles.add("videogenTestFile/example6Bad.videogen");
		badfiles.add("videogenTestFile/example7Bad.videogen");
		badfiles.add("videogenTestFile/example8Bad.videogen");
		badfiles.add("videogenTestFile/example9Bad.videogen");
		for(String file : files){
			val video = new VideoGenHelper().loadVideoGenerator(file);
			var generetor = new Generator();
			
			assertFalse(generetor.hasError(video));
		}
		
		for(String file : badfiles){
			val video = new VideoGenHelper().loadVideoGenerator(file);
			var generetor = new Generator();
			
			assertTrue(generetor.hasError(video));
		}
		
	}
	
}
