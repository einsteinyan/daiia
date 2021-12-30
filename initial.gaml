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
	int stayTime <- 25;
	
	float musicTaste <- rnd(float(1));
	float sociability <- rnd(float(1));
	float money <- rnd(float(1));
	
	float eatQuotient <- rnd(float(1));
	float drinkQuotient <- rnd(float(1));
	
	float fullfillment <- 0.0;
	
	init {
		totalFullfillment <- totalFullfillment + fullfillment; 
	}
	
	reflex decide when: !hasTarget {
		if (type = 'Cop' or type = 'Thief') {
			do wander speed: 5.0;
		}
		else if (type = 'ConcertGoer'){
			targetPoint <- concertLocation;
			hasTarget <- true;
		}
		else if (type = 'partyGoer'){
			targetPoint <- eatQuotient > drinkQuotient ? restaurantLocation : barLocation; // line???
			hasTarget <- true;
		}
		else {
			int randomShop <- rnd(2);
			targetPoint <- shopLocation at randomShop;
			hasTarget <- true;
		}
	}
	
	reflex interactWithOthers when: goalAchieved {
		
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
		do wander speed: 5.0;
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
	bool decidedStayLength <- false;
	
	reflex checkCrowd when: atTarget and !decidedStayLength {
		agent closestAgent <- agent_closest_to(self);
		ask closestAgent {
			if (abs(myself.musicTaste - musicTaste) < 0.2) {
				myself.stayTime <- 50;
				stayTime <- 50;
				write myself.name + name + "found a musicmate";
			}
		}
		decidedStayLength <- true;
		concertGoerFullfillment <- concertGoerFullfillment + 0.1;
		totalFullfillment <- totalFullfillment + concertGoerFullfillment;
	}
	
	reflex enjoyConcert when: atTarget and decidedStayLength {
		do wander;
		if (stayTime > 0) {
			stayTime <- stayTime - 1;	
		}
		else {
			fullfillment <- fullfillment + 0.1;
			goalAchieved <- true;
		}
	}
}

species partyGoer parent: people skills: [fipa, moving] {
	rgb color <- #lightgreen;
	string type <- 'partyGoer';
	
	reflex socialise when: (atTarget and sociability > 0.5) {
		do wander;
		agent closestAgent <- agent_closest_to(self);
		ask closestAgent {
			if (sociability > 0.75) {
				write myself.name + name + "Found someone to hangout with";
				partyGoerFullfillment <- partyGoerFullfillment + 0.1;
				totalFullfillment <- totalFullfillment + partyGoerFullfillment;
			} 
		}	
	}
	
	reflex buySomething when: (atTarget and sociability < 0.5 and money > 0.5) {
		money <- money - rnd(money);
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
}

species shopper parent: people skills: [fipa, moving] {
	rgb color <- #lightyellow;
	string type <- 'shopper';
	list<shop> shopsList;
	float lowestPrice <- 1.0;
	bool buyItem <- false;
	
	init {
		shopsList <- list(shop);
	}
	
	reflex goShopping when: empty(proposes) and atTarget and money > 0.5 {
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
	
	reflex chatWithShoppers when: atTarget and money < 0.5 {
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
