import java.io.File
import java.util.ArrayList
import java.util.Random
import org.eclipse.emf.common.util.EList
import org.junit.Test
import org.xtext.example.mydsl.videoGen.AlternativesMedia
import org.xtext.example.mydsl.videoGen.MandatoryMedia
import org.xtext.example.mydsl.videoGen.Media
import org.xtext.example.mydsl.videoGen.MediaDescription
import org.xtext.example.mydsl.videoGen.OptionalMedia
import org.xtext.example.mydsl.videoGen.VideoDescription
import org.xtext.example.mydsl.videoGen.VideoGeneratorModel

import static org.junit.Assert.*

class Generator {

	// liste des id pour le csv
	var listeid = new ArrayList<String>;
	var util = new Util();

	def void generate(VideoGeneratorModel videoGen, String locationFileVideo) {
		var playlist = new ArrayList<VideoDescription>();
		// val videoGen = new VideoGenHelper().loadVideoGenerator(URI.createURI("example2.videogen"))
		for (Media media : videoGen.medias) {

			if (media instanceof MandatoryMedia) {
				if (media.description instanceof VideoDescription) {

					playlist.add(videoMandatory(media.description as VideoDescription));
				}

			} else if (media instanceof OptionalMedia) {
				if (media.description instanceof VideoDescription) {
					playlist.add(videoOptional(media.description as VideoDescription));
				}

			} else if (media instanceof AlternativesMedia) {
				playlist.add(videoAlternative((media as AlternativesMedia).medias));
			}
		}
		// execute commande 
		util.generateVideo(playlist, locationFileVideo);

	}

	def private VideoDescription videoOptional(VideoDescription description) {
		val rand = new Random();
		val random = rand.nextInt(100);
		if (description.probability == 0 && 50 >= random) {
			//println(description.location);
			return description;
		} else if (description.probability >= random) {
			//println(description.location);
			return description;
		}
	}

	def private VideoDescription videoMandatory(VideoDescription description) {
		//println(description.location);
		return description;
	}

	def private VideoDescription videoAlternative(EList<MediaDescription> descriptions) {
		val rand = new Random();
		val random = rand.nextInt(100);
		var videochoose = null;
		for (MediaDescription media : descriptions) {
			if (media instanceof VideoDescription) {
				val video = (media as VideoDescription);
				if (video.probability >= random) {

					//println(video.location);
					return (video);
				}
			}
		}

		if (videochoose === null) {
			val random2 = rand.nextInt(descriptions.size);
			//println(descriptions.get(random2).location);
			return (descriptions.get(random2) as VideoDescription);
		}

	}
	
	def void generateGif(VideoGeneratorModel videoGen){
		for (Media media : videoGen.medias) {

			if (media instanceof MandatoryMedia) {
				if (media.description instanceof VideoDescription) {

					util.generateGif((media.description as VideoDescription).location);

				}

			} else if (media instanceof OptionalMedia) {
				if (media.description instanceof VideoDescription) {
					util.generateGif((media.description as VideoDescription).location);

				}

			} else if (media instanceof AlternativesMedia) {
				for (MediaDescription mediaAlter : media.medias) {
					if (mediaAlter instanceof VideoDescription) {
						util.generateGif((mediaAlter as VideoDescription).location);
					}
				}
			}
		}
	}

	/**
	 * Creer des vignettes pour toutes les videos
	 */
	def void createVignetteVarianteModel(VideoGeneratorModel videoGen) {

		for (Media media : videoGen.medias) {

			if (media instanceof MandatoryMedia) {
				if (media.description instanceof VideoDescription) {

					util.generateVignette((media.description as VideoDescription).location);

				}

			} else if (media instanceof OptionalMedia) {
				if (media.description instanceof VideoDescription) {
					util.generateVignette((media.description as VideoDescription).location);

				}

			} else if (media instanceof AlternativesMedia) {
				for (MediaDescription mediaAlter : media.medias) {
					if (mediaAlter instanceof VideoDescription) {
						util.generateVignette((mediaAlter as VideoDescription).location);
					}
				}
			}
		}

	}

	
	def public boolean hasError(VideoGeneratorModel videoGen) {
		
		var good = false;
		for (Media media : videoGen.medias) {

			if (media instanceof MandatoryMedia) {
				if (media.description instanceof VideoDescription) {
					var id = (media.description as VideoDescription).videoid;
					if (!listeid.contains(id)) {
						listeid.add(id);

					} else {
						println("id déja présent : " + id);
						good=true;
					}

					if (!new File((media.description as VideoDescription).location).exists) {
						println(id + " : le fichier n'existe pas");
						good=true;
					}

				}

			} else if (media instanceof OptionalMedia) {
				
				if (media.description instanceof VideoDescription) {
					
					var id = (media.description as VideoDescription).videoid;
					if (!listeid.contains(id)) {
						listeid.add(id);

					} else {
						println("id déja présent : " + id);
						good=true;
						
					}
					if ((media.description as VideoDescription).probability > 100) {
						println(id + " : probalité doit être compris entre 0 et 100");
						good=true;
						
					}
					if ((media.description as VideoDescription).probability < 0) {
						println(id + " : probalité doit être compris entre 0 et 100");
						good=true;
						
					}

					if (!new File((media.description as VideoDescription).location).exists) {
						println(id + " : le fichier n'existe pas");
						good=true;
						
					}

				}

			} else if (media instanceof AlternativesMedia) {

				good = good ||  errorAlternativeInterpretation(media)

			}
			

		}
		return good;

	}

	def boolean  errorAlternativeInterpretation(AlternativesMedia alternative) {
		var total = 0;
		var good = false;
		for (MediaDescription media : alternative.medias) {
			if (media instanceof VideoDescription) {
				var id = (media as VideoDescription).videoid;
				if (!listeid.contains(id)) {
					listeid.add(id);

				} else {
					good=true;
					println("id déja présent : " + id);
				}
				total = total + (media as VideoDescription).probability;
				if (!new File((media as VideoDescription).location).exists) {
					println(id + " : le fichier n'existe pas");
					good=true;
				}
			}
		}

		if (total != 100) {
			if (total != 0) {
				println(alternative.id + " : le total doit être de 100");
				good=true;
			}
		}
		return good;
	}

}
