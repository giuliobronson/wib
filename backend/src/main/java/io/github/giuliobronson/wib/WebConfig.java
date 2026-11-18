package io.github.giuliobronson.wib;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Prefixa todos os {@link RestController} com {@code /api}, alinhado ao proxy do Vite.
 */
@Configuration
class WebConfig implements WebMvcConfigurer {

	@Override
	public void configurePathMatch(PathMatchConfigurer configurer) {
		configurer.addPathPrefix("/api", c -> c.isAnnotationPresent(RestController.class));
	}

}
