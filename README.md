# ParaShop Microservices Project

Ce projet est une plateforme e-commerce basée sur une architecture microservices utilisant Spring Cloud. Il comprend des services pour la gestion des produits, de l'inventaire, des commandes, de la fidélité et de l'authentification.

## Architecture du Projet

Le projet est composé des modules suivants :

- **Discovery Service** (Eureka) : Gère l'enregistrement et la découverte des services (Port: 8761).
- **Config Service** : Centralise la configuration de tous les microservices (Port: 8085).
- **Gateway Service** : Point d'entrée unique pour toutes les requêtes clients (Port: 8888).
- **Auth Service** : Gère l'authentification et les comptes utilisateurs (Port: 8080).
- **Product Service** : Gère le catalogue des produits (Port: 8081).
- **Inventory Service** : Gère le stock des produits (Port: 8082).
- **Order Service** : Gère le processus de commande (Port: 8083).
- **Loyalty Service** : Gère les points de fidélité des utilisateurs (Port: 8084).

## Accès aux Services

Il existe deux façons d'accéder aux services :

### 1. À travers le Gateway (Recommandé)

Le Gateway agit comme un proxy et un filtre de sécurité. Toutes les requêtes passent par le port `8888`.

| Service | Chemin Gateway | Exemple URL (Navigateur) |
| :--- | :--- | :--- |
| **Product** | `/api/product` | `http://localhost:8888/api/product` |
| **Inventory** | `/api/inventory` | `http://localhost:8888/api/inventory` |
| **Loyalty** | `/api/loyalty` | `http://localhost:8888/api/loyalty/1` |
| **Auth** | `/auth/**` | *(Nécéssite un client API comme Postman)* |
| **Order** | `/api/order/**` | *(Nécéssite un client API comme Postman)* |

> [!NOTE]
> La plupart des services (sauf Auth) nécessitent un jeton JWT valide dans le header `Authorization: Bearer <token>`.

### 2. Accès Direct (Développement/Debug)

Chaque service peut être accédé directement via son port spécifique.

| Service | Port | Base URL |
| :--- | :--- | :--- |
| **Config** | 8085 | `http://localhost:8085` |
| **Eureka** | 8761 | `http://localhost:8761` |
| **Auth** | 8080 | `http://localhost:8080` |
| **Product** | 8081 | `http://localhost:8081` |
| **Inventory** | 8082 | `http://localhost:8082` |
| **Order** | 8083 | `http://localhost:8083` |
| **Loyalty** | 8084 | `http://localhost:8084` |

## Données de Test (Auto-générées)

Au démarrage, les bases de données sont automatiquement peuplées avec des données de test via la classe `DataInitializer` de chaque service.

### Utilisateurs par défaut
- **Admin** : `admin` / `admin123`
- **User** : `user` / `user123`

### Produits de test
- **Laptop Dell XPS 15** (Code: `DELL-XPS-15`)
- **iPhone 15 Pro** (Code: `IPHONE-15-PRO`)
- **Samsung Galaxy Buds 2** (Code: `GALAXY-BUDS-2`)

## Comment Lancer le Projet

1. Lancez d'abord le **Discovery Service**.
2. Lancez le **Config Service**.
3. Lancez le **Gateway Service**.
4. Lancez les autres services dans n'importe quel ordre.
