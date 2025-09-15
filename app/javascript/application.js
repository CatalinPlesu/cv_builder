// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
document.addEventListener("DOMContentLoaded", () => {
	handleFlashNotifications();
});

document.addEventListener("turbo:load", () => {
	handleFlashNotifications();
});

function handleFlashNotifications() {
	const flashMessages = document.querySelectorAll(
		".flash-notice, .flash-alert",
	);

	flashMessages.forEach((flash) => {
		// Auto-remove after 5 seconds
		setTimeout(() => {
			removeFlash(flash);
		}, 5000);

		// Click to remove
		flash.addEventListener("click", () => {
			removeFlash(flash);
		});
	});
}

function removeFlash(element) {
	element.classList.add("animate-fade-out");

	element.addEventListener("animationend", () => {
		element.remove();

		// If no more flash messages, remove container
		const flashContainer = document.getElementById("flash-container");
		if (flashContainer && flashContainer.children.length === 0) {
			flashContainer.remove();
		}
	});
}
