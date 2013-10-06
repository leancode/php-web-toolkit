/*
 * ysr.com - global JS-include
 * @uses Mootools core+more äöü
 *
 * @author Mario Fischer <mario@chiprweck.de>
 */

var Ysr = new Class({
 
	Implements: [Options, Events],
	options: {
    	debug: true
	},

    initialize: function(options) {
		this.setOptions(options);
	},

	slowDissolve: function(els)
	{
		els.each(function(el) {
			var fc = function() {
				if (el.getStyle('display') != 'none') {
					el.dissolve({duration: 1200, transition: 'quad:in:out'});
				}
			};
			fc.delay(5000);
		});
	},

	errTween: function(els)
	{
		els.each(function(el) {
			var fc = function() {
				el.set('tween', {'duration': 'long'});
				el.tween('background-color', '#fd87d3', '#9D2763');
			};
			fc.delay(2000);
		});
	},

	attachTips: function(els)
	{
		els.each(function(el) {
			var myTips = new Tips(el, {
				onShow: function() {
					this.tip.setStyle('opacity', 0);
					this.tip.set('tween', {wait: false});
					this.tip.tween('opacity', [0, 1]);

				},
				onHide: function() {
					this.tip.setStyle('opacity', 1);
					this.tip.set('tween', {wait: false});
					this.tip.tween('opacity', [1, 0]);
				}
			});
		});
	},

	morphBtn: function(els)
	{
		els.each(function(el) {
			var fxbtn = new Fx.Morph(el, {duration: 400, transition: Fx.Transitions.Sine.easeOut});
			var bgcolor = el.getStyle('background-color');
			var fgcolor = el.getStyle('color');			

			el.addEvents({
				'mouseover':function(){
					fxbtn.cancel();
					fxbtn.start('.hover');
				},
				'mouseout':function(){
					fxbtn.cancel();
					fxbtn.start({'background-color':bgcolor, 'color':fgcolor});
				}
			});
		});
	},
	
	naviTween: function(els)
	{
		els.each(function(el) {
			var fxbtn = new Fx.Morph(el, {duration: 200, transition: Fx.Transitions.Sine.easeIn});
			if (el.hasClass('naviactive')) {
				el.addEvents({
					'mouseover':function(){
						fxbtn.cancel();
						fxbtn.start('.naviactive');
					},
					'mouseout':function(){
						fxbtn.cancel();
						fxbtn.start('.naviinactive');
					}
				});
			} else {
				el.addEvents({
					'mouseover':function(){
						fxbtn.cancel();
						fxbtn.start('.naviactive');
					},
					'mouseout':function(){
						fxbtn.cancel();
						fxbtn.start('.naviinactive');
					}
				});
			}
		});
	},	

	accordionSetup: function(els, togglers, targets)
	{
		els.each(function(el) {
			myAccordion = new Fx.Accordion($$(togglers), $$(targets), {
				opacity: true,
				show: 0,
				display: 0,
				alwaysHide: false,
				onActive: function(toggler, element){
					toggler.addClass('active');
				},
				onBackground: function(toggler, element){
					toggler.removeClass('active');
				}
			});
		});
	}
});

Ysr.markAsRead = function(id, counterfield) {
	var newsitem = 'event'+id;
	if ($(newsitem)) {
		$(newsitem).dissolve();
		var myRequest = new Request({url: '/ajax.php'}).send("action=markread&value=" + id);
	}
	if ($(counterfield)) {
		var count = $(counterfield).get('text').toInt();
		if (count > 1) {
			$(counterfield).set('text', count-1);
		}
	}
};

Ysr.markAsDeleted = function(id, counterfield) {
	var newsitem = 'msg'+id;
	if ($(newsitem)) {
		$(newsitem).dissolve(); // $(newsitem).highlight('#7e0051');
		var myRequest = new Request({url: '/ajax.php'}).send("action=markdeleted&value=" + id);
	}
	if ($(counterfield)) {
		var count = $(counterfield).get('text').toInt();
		if (count > 1) {
			$(counterfield).set('text', count-1);
		}
	}
};

Ysr.vote = function(id, score) {
	var myRequest = new Request({
		url: '/ajax.php',
		onSuccess: function(responseText, responseXML) {
			if (responseText == "1" || responseText == "5") {

				var fxr = new Fx.Tween($('uservoting'), {duration: 500, property: 'opacity'});
				var fxs = new Fx.Tween($('uservotingdone'), {duration: 500, property: 'opacity'});

				fxr.start(0).chain(function() {
					 $('uservoting').dispose();
					 this.callChain();
				}).chain(function() {
					fxs.start(1);
					this.callChain();
				}).chain(function() {
					(function() {
						$('uservotingnum').highlight('#999');
						var users = $('uservotingnum').get('text').toInt();
						users++;
						if (users == 1) {
							$('uservotingnum').set('html', "<strong>" + users + "</strong> user thinks that this style rocks.");
						} else {
							$('uservotingnum').set('html', "<strong>" + users + "</strong> users think that this style rocks.");
						}
						(function() {$('uservotingdone').highlight('#999'); }).delay(800);	
					}).delay(500);
				});
			}
		}
	});
	myRequest.send("action=vote&key=" + id + "&value=" + score);
};


var obj = {
    name: 'Anton'
  , handle: 'valueof'
  , role: 'SW Engineer'
};