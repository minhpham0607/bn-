package com.example.hrms.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.core.GrantedAuthorityDefaults;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

import static org.springframework.security.web.util.matcher.AntPathRequestMatcher.antMatcher;
import static org.springframework.security.config.Customizer.withDefaults;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity // Kích hoạt @PreAuthorize và các annotation bảo mật khác
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/bookings/**",
                                "/api/v1/bookings/**",
                                "/meeting-room/**",
                                "/api/v1/meeting-room/**",
                                "/departments/**",
                                "/roles/**",
                                "/api/v1/roles/**",
                                "/requests/**",
                                "/api/v1/requests/**",
                                "/users/**",
                                "/api/v1/users/login",
                                "/api/v1/users/all",
                                "/api/v1/users/check",
                                "/api/v1/users/getUserByUsername/").permitAll()
                        .requestMatchers("/css/**", "/js/**", "/images/**", "/fonts/**", "users/login","users/home").permitAll()
                        .requestMatchers("/api/v1/users/create/**").hasAnyAuthority("ADMIN", "SUPERVISOR")
                        .requestMatchers("/api/v1/users/update/**").hasAnyAuthority("ADMIN", "SUPERVISOR")
                        .requestMatchers("/api/v1/users/delete/**")
                        .hasAuthority("ADMIN") // Chỉ Admin mới được xóa người dùng

                        .anyRequest().authenticated()
                ).sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(withDefaults()); // Thay vì httpBasic(), dùng httpBasic(withDefaults())

        return http.build();
    }

    @Bean
    public GrantedAuthorityDefaults grantedAuthorityDefaults() {
        // Remove the default "ROLE_" prefix
        return new GrantedAuthorityDefaults("");
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}