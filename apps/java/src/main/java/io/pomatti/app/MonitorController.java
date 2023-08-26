package io.pomatti.app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MonitorController {

	@GetMapping("/monitor")
	public void index() {
		// var appics = System.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING");
		// System.out.println("Connection string: " + appics);
		System.out.println("Writing to log");
	}

}
