function log() {
	console.log.apply(console, arguments);
}


window.addEventListener('load', function() {
	var element = document.querySelector('.gimme-button');
	if (!element) {
		alert("No element with class .gimme-button detected!");
		return;
	}

	var iframe = document.createElement('iframe');
	iframe.src = 'http://localhost:3000/button';
	iframe.width = 200;
	iframe.height = 100;
	iframe.style.border = 'none';
	// uncomment to show border 
	//iframe.style.border = '1px solid #ccc';
	
	element.appendChild(iframe);
});

