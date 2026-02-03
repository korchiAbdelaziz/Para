package com.parashop.loyalty_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class LoyaltyServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(LoyaltyServiceApplication.class, args);
	}

}
