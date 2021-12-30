/**
* Name: initial
* Based on the internal empty template. 
* Author: einsteinyan
* Tags: 
*/


model festivalSimulation

/* Insert your model definition here */

global {
	int numberOfBars <- 1;
	int numberOfPeople <- 20;
	int numberOfConcerts <- 1;
	int numberOfRestaurants <- 1;
	int numberOfShops <- 3;
	int numberOfCops <- 5;
	int numberOfTheives <- 5;
	
	point concertLocation <- {50, 50};
	point barLocation <- {50, 25};
	point restaurantLocation <- {50, 75};
	list<point> shopLocation <- [{25, 50}, {25, 40}, {25, 60}];
	int i <- 0;
	
	float totalFullfillment <- 0.0;
	
	float copFullfillment <- 0.0;
	float thiefFullfillment <- 0.0;
	float concertGoerFullfillment <- 0.0;
	float partyGoerFullfillment <- 0.0;
	float shopperFullfillment <- 0.0;
	
	init {
		create bar number: numberOfBars {
			location <- barLocation;
		}
		create concert number: numberOfConcerts {
			location <- concertLocation;
		}
		create restaurant number: numberOfRestaurants {
			location <- restaurantLocation;
		}
		create shop number: numberOfShops {
			location <- shopLocation at i;
			i <- i+1;
		}
		create concertGoer number: numberOfPeople {
			location <- {rnd(100), rnd(100)};
		}
		create partyGoer number: numberOfPeople {
			location <- {rnd(100), rnd(100)};
		}
		create shopper number: numberOfPeople {
			location <- {rnd(100), rnd(100)};
		}
		create cop number: numberOfCops {
			location <- {rnd(100), rnd(100)};
		}
		create thief number: numberOfTheives {
			location <- {rnd(100), rnd(100)};
		}
	}
}


species bar skills: [fipa] {
	string typeBar;
	rgb colorBar <- #green;
	
	//draw bar
	aspect default {
//		draw box(12, 8, 5) color: colorBar;
		draw rectangle(12, 8) color: colorBar;
	}
	
}

species concert skills: [fipa] {
	string typeBar;
	rgb colorBar <- #coral;
	
	//draw bar
	aspect default {
//		draw cylinder(10, 8) color: colorBar;
		draw circle(10) color: colorBar;
	}
	
}

species restaurant skills: [fipa] {
	string typeBar;
	rgb colorBar <- #green;
	
	//draw bar
	aspect default {
//		draw box(12, 8, 4) color: colorBar;
		draw rectangle(12, 8) color: colorBar;
	}
	
}

species shop skills: [fipa] {
	string typeBar;
	rgb colorBar <- #yellow;
	
	reflex communicatePrices when: !empty(cfps) {
		float price <- rnd(float(0.5));
		loop c over: cfps {  //c = the message from one of requesting guests
			do propose (message: c, contents:[price]);
		}
	}
	
	//draw bar
	aspect default {
//		draw box(4, 6, 4) color: colorBar;
		draw rectangle(4, 6) color: colorBar;
	}
	
}

species people skills: [fipa, moving] {
	rgb myColor <- #black;
	rgb color <- #darkslategrey;
	
	string type;
	point targetPoint <- nil;
	bool hasTarget <- false;
	bool atTarget <- false;
	bool goalAchieved <- false;
	bool isInteracting <- false;
	bool isWandering <- false;
	bool alternateDestination <- false;
	bool decidedStayLength <- false;
	int stayTime <- 25;
	int wanderingTime <- 50;
	list<shop> shopsList;
	float lowestPrice <- 1.0;
	bool buyItem <- false;
	
	float musicTaste <- rnd(float(1));
	float sociability <- rnd(float(1));
	float money <- rnd(float(1));
	
	float eatQuotient <- rnd(float(1));
	float drinkQuotient <- rnd(float(1));
	float goalQuotient <- rnd(float(1));
	string currentGoal <- nil;
	
	float fullfillment <- 0.0;
	
	init {
		shopsList <- list(shop);
		totalFullfillment <- totalFullfillment + fullfillment; 
	}
	
	action resetVal {
		
	}
	
	reflex decide when: !hasTarget {
		if(!alternateDestination) {
			if (type = 'Cop' or type = 'Thief') {
				do wander speed: 5.0;
				currentGoal <- 'wander';
			}
			else if (type = 'ConcertGoer'){
				targetPoint <- concertLocation;
				hasTarget <- true;
				currentGoal <- 'goto_concert';
			}
			else if (type = 'partyGoer'){
				targetPoint <- eatQuotient > drinkQuotient ? restaurantLocation : barLocation;
				hasTarget <- true;
				currentGoal <- 'goto_party';
			}
			else {
				int randomShop <- rnd(2);
				targetPoint <- shopLocation at randomShop;
				hasTarget <- true;
				currentGoal <- 'goto_shop';
			}	
		}
		else {
//			if (type = 'Cop' or type = 'Thief') {
//				do wander speed: 5.0;
//				currentGoal <- 'wander';
//			}
//			else if (type = 'ConcertGoer'){
//				targetPoint <- concertLocation;
//				hasTarget <- true;
//				currentGoal <- 'goto_concert';
//			}
//			else if (type = 'partyGoer'){
//				targetPoint <- eatQuotient > drinkQuotient ? restaurantLocation : barLocation;
//				hasTarget <- true;
//				currentGoal <- 'goto_party';
//			}
//			else {
//				int randomShop <- rnd(2);
//				targetPoint <- shopLocation at randomShop;
//				hasTarget <- true;
//				currentGoal <- 'goto_shop';
//			}	

			if (type = 'ConcertGoer'){
				if(sociability > 0.5) {
					targetPoint <- eatQuotient > drinkQuotient ? restaurantLocation : barLocation;
					hasTarget <- true;
					currentGoal <- goalQuotient > 0.5 ? 'goto_party' : 'socialise';  
				}
				else {
					if (money > 0.5) {
						int randomShop <- rnd(2);
						targetPoint <- shopLocation at randomShop;
						hasTarget <- true;
						currentGoal <- goalQuotient > 0.5 ? 'goto_shop' : 'socialise';
					}
					else {
//						do wander;
						currentGoal <- goalQuotient > 0.5 ? 'goto_eat' : 'socialise';
						hasTarget <- true;
					}
				}
			}
			else if (type = 'partyGoer'){
				if(musicTaste > 0.5) {
					targetPoint <- concertLocation;
					hasTarget <- true;
					currentGoal <- goalQuotient > 0.5 ? 'goto_party' : 'socialise';
				}
				else {
					if (money > 0.5) {
						int randomShop <- rnd(2);
						targetPoint <- shopLocation at randomShop;
						hasTarget <- true;
						currentGoal <- goalQuotient > 0.5 ? 'goto_shop' : 'socialise';
					} 
					else {
//						do wander;
						hasTarget <- true;
					}
				}
			}
			else if (type = 'shopper'){
				if(musicTaste > 0.5) {
					targetPoint <- concertLocation;
					hasTarget <- true;
					currentGoal <- goalQuotient > 0.5 ? 'goto_concert' : 'socialise';
				}
				else {
					targetPoint <- eatQuotient > drinkQuotient ? restaurantLocation : barLocation;
					hasTarget <- true;
					currentGoal <- goalQuotient > 0.5 ? 'goto_party' : 'socialise';
				}
			}	
		}
	}
	
	
	reflex moveToTarget when: hasTarget {
		if (location distance_to(targetPoint) > 5) {
			do goto target: targetPoint;
			speed <- 2.0;	
		}
		else {
			atTarget <- true;
		}
	}
	
	reflex wanderAway when: goalAchieved {
		if (wanderingTime > 0) {
			do wander speed: 20.0;
			wanderingTime <- wanderingTime - 1;	
		}	
		else {
			// Reset flags 
			goalAchieved <- false;
			hasTarget <- false;
			atTarget <- false;
			stayTime <- 25;
			wanderingTime <- 50;
			alternateDestination <- true;
		}
	}
	
	
	
	reflex beginInteracting when: atTarget and currentGoal = 'socialise' {
		list neighbours <- (self neighbors_at 5) of_species (species (self));
		if(!empty(neighbours)) {
			loop person over: neighbours {
				if(person.sociability > 0.5) {
					person.myColor <- #red;
					person.isInteracting <- true;
					person.atTarget <- false;
					person.fullfillment <- person.fullfillment + 0.1;
				}			
			}
			if (sociability > 0.5) {				
				myColor <- #red;
				isInteracting <- true;
				atTarget <- false;	
				fullfillment <- fullfillment + 0.1;
			}
		}
	}
	
	reflex interactWithOthers when: isInteracting {
		if(stayTime > 0) {
//			agent closestAgent <- agent_closest_to(self);
			if (type = 'ConcertGoer') {
				write name + "is interacting";
			}
			else if (type = 'partyGoer') {
				write name + "is interacting";
			}
			else if (type = 'shopper') {
				write name + "is interacting";
			}	
			stayTime <- stayTime - 1;
		}
		else {
			goalAchieved <- false;
			hasTarget <- false;
			atTarget <- false;
			stayTime <- 25;
			wanderingTime <- 50;
//			alternateGoal <- true;
			isInteracting <- false;
		}
	}

	//	Things to do in the concert
	reflex checkCrowd when: currentGoal = 'goto_concert' and atTarget and !decidedStayLength {
		agent closestAgent <- agent_closest_to(self);
		ask closestAgent {
			if (abs(myself.musicTaste - musicTaste) < 0.2) {
				myself.stayTime <- 50;
				stayTime <- 50;
				write myself.name + " and " + name + " will stay longer at the concert.";
			} 
		}
		decidedStayLength <- true;
		concertGoerFullfillment <- concertGoerFullfillment + 0.1;
		totalFullfillment <- totalFullfillment + concertGoerFullfillment;
	}
	
	reflex enjoyConcert when: currentGoal = 'goto_concert' and atTarget and decidedStayLength {
		do wander;
		if (stayTime > 0) {
			stayTime <- stayTime - 1;	
		}
		else {
			decidedStayLength <- false;
			fullfillment <- fullfillment + 0.1;
			goalAchieved <- true;
		}
	}
	
	//	Things to do in the party	
	reflex socialise when: (currentGoal = 'goto_party' and atTarget and sociability > 0.5) {
		do wander;
		agent closestAgent <- agent_closest_to(self);
		ask closestAgent {
			if (sociability > 0.75) {
				string place <- myself.eatQuotient > myself.drinkQuotient ? 'bar' : 'restaurant';
				write myself.name + " is partying with " + name + " at the " + place;
				partyGoerFullfillment <- partyGoerFullfillment + 0.1;
				totalFullfillment <- totalFullfillment + partyGoerFullfillment;
			} 
		}	
	}
	
	reflex buySomething when: (currentGoal = 'goto_party' and atTarget and sociability < 0.5 and money > 0.5) {
		money <- money - rnd(money*0.5);
		goalAchieved <- true;
		if (eatQuotient > drinkQuotient) {
			eatQuotient <- eatQuotient - rnd(eatQuotient);
			write "Bought something to eat at restaurant.";
		}
		else {
			drinkQuotient <- drinkQuotient - rnd(drinkQuotient);
			write "Bought something to drink at bar.";
		}
	} 
	
	reflex buySomething when: (currentGoal = 'goto_party' and atTarget and sociability < 0.5 and money < 0.5) {
		if (stayTime > 0) {
			do wander;
			stayTime <- stayTime - 1;	
		}
		else {
			goalAchieved <- true;
			fullfillment <- fullfillment + 0.1;
		}
	}
	
	//	Things to do while shopping 
	
	reflex goShopping when: currentGoal = 'goto_shop' and empty(proposes) and atTarget and money > 0.5 {
		do start_conversation(to: shopsList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [self]);
	}
	
	reflex getPrices when: (!empty(proposes)) {
		loop p over: proposes {
			list contents <- p.contents;
			float proposedPrice <- float(contents at 0);
//			write shop(p.sender).name + " has proposed " + proposedPrice + " " + name;
			lowestPrice <- proposedPrice < lowestPrice ? proposedPrice : lowestPrice;
		}
		buyItem <- true;
	}
	
	reflex buyItem when: buyItem and !goalAchieved {
		money <- money - lowestPrice;
		write name + " has bought at item for " + lowestPrice;
		goalAchieved <- true;
		fullfillment <- fullfillment + 0.1;
		totalFullfillment <- totalFullfillment + fullfillment;
	}
	
	reflex chatWithShoppers when: currentGoal = 'goto_shop' and atTarget and money < 0.5 {
		if (stayTime > 0) {
			do wander;
			stayTime <- stayTime - 1;	
		}
		else {
			goalAchieved <- true;
			shopperFullfillment <- shopperFullfillment + 0.1;
			totalFullfillment <- totalFullfillment + shopperFullfillment;
		}
	}
	
	aspect default {
		draw sphere(0.75) at: {location.x, location.y, 1.25} color: color;
		draw pyramid(2) at: location  color: myColor;
	}
	
} 

species cop parent: people skills: [fipa, moving] {
	rgb color <- #lightskyblue;
	rgb myColor <- #blue;
	string type <- 'Cop';
	
	reflex SearchThief when: true {
		agent closestAgent <- agent_closest_to(self);
		ask closestAgent {
			if (type = 'Thief'){
				write myself.name + name + "found a thief";
			}
		}
		copFullfillment <- copFullfillment + 0.1;
		totalFullfillment <- totalFullfillment + copFullfillment;
	}
}

species thief parent: people skills: [fipa, moving] {
	rgb color <- #orange;
	rgb myColor <- #orangered;
	float money_stolen <- 0.0;
	string type <- 'Thief';
	
	reflex Steal when: true {
		agent closestAgent <- agent_closest_to(self);
		ask closestAgent {
			if (location distance_to(myself.location) < 1) and not (type = 'Cop') and not (type = 'Thief'){
				write myself.name + name + "steal a guest";
				money <- money - 0.1;
				myself.money_stolen <- myself.money_stolen + 0.1;
				thiefFullfillment <- thiefFullfillment + 0.1;
				totalFullfillment <- totalFullfillment + thiefFullfillment;
			}
		}
	}
}

species concertGoer parent: people skills: [fipa, moving] {
	rgb color <- #lightcoral;
	string type <- 'ConcertGoer';
}

species partyGoer parent: people skills: [fipa, moving] {
	rgb color <- #lightgreen;
	string type <- 'partyGoer';
}

species shopper parent: people skills: [fipa, moving] {
	rgb color <- #yellow;
	string type <- 'shopper';
}

experiment simulation type: gui {
	output {
		display main type: opengl {
			species bar;
			species restaurant;
			species concert;
			species shop;
			species cop;
			species thief;
			species concertGoer;
			species partyGoer;
			species shopper;
		}
		monitor "Overall fullfillment" value: totalFullfillment;
		display simInformation refresh: every(100#cycles) {
			chart "Global fullfillment" type: series size:{1, 0.5} position: {0, 0} {
				data "Fullfillment" value: totalFullfillment color: #blue;
				
				data "CopFullfillment" value: copFullfillment color: #red;
				data "ThiefFullfillment" value: thiefFullfillment color: #black;
				data "PartyGoerFullfillment" value: partyGoerFullfillment color: #orange;
				data "ConcertGoerFullfillment" value: concertGoerFullfillment color: #green;
				data "ShopperFullfillment" value: shopperFullfillment color: #yellow;
			}
		}
	}
}
