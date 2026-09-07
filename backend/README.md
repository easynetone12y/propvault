# PropVault — Backend

Spring Boot 3.2 REST API serving the PropVault real estate marketplace.

## Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| Java | 17 LTS | Language |
| Spring Boot | 3.2.3 | Framework |
| Spring Security | 6.x | JWT auth + RBAC |
| Spring Data JPA | 3.x | ORM layer |
| PostgreSQL | 15+ | Primary database |
| Flyway | 9.x | Schema migrations |
| Redis | 7.x | JWT blacklist / cache |
| AWS S3 SDK | 2.23 | Media file storage |
| Razorpay Java SDK | — | Subscription payments |
| Spring Mail | — | Transactional email |
| SpringDoc OpenAPI | 2.3 | Swagger UI |
| Lombok | — | Boilerplate reduction |
| MapStruct | 1.5.5 | DTO mapping |

## Package Structure

```
com.propvault/
├── PropVaultApplication.java     # @SpringBootApplication entry point
├── config/
│   ├── AppConfig.java            # RestTemplate, ObjectMapper beans
│   ├── AwsConfig.java            # S3Client, S3Presigner beans
│   └── SecurityConfig.java       # Filter chain, CORS, route guards
├── controller/                   # 11 REST controllers
├── service/                      # 10 interfaces + 10 implementations
├── entity/                       # 14 JPA entities
├── repository/                   # 12 Spring Data JPA repositories
├── dto/
│   ├── request/                  # 9 validated request DTOs
│   └── response/                 # 14 response DTOs
├── enums/                        # 7 enums (UserRole, PropertyStatus…)
├── security/
│   ├── filter/JwtAuthenticationFilter.java
│   └── service/JwtService.java
├── exception/
│   ├── ApiException.java         # Factory methods: notFound, badRequest…
│   └── GlobalExceptionHandler.java
└── util/
    └── SecurityUtil.java         # getCurrentUser, getCurrentAgentId helpers
```

## Running Locally

```bash
# Prerequisites: Java 17+, PostgreSQL 15+, Redis 7+, Maven 3.8+

# 1. Create database
psql -U postgres -c "CREATE DATABASE propvault_db;"

# 2. Set environment variables (see .env.example)
cp .env.example .env
# Edit .env with your values

# 3. Run
mvn spring-boot:run

# API:    http://localhost:8080/api/v1
# Swagger: http://localhost:8080/swagger-ui.html
```

## Database Migrations

| Migration | File | Contents |
|-----------|------|----------|
| V1 | `V1__init_schema.sql` | All core tables, indexes, FTS vector, triggers |
| V2 | `V2__visits_notifications_saved.sql` | Visits, notifications, saved_properties, analytics |
| V3 | `V3__password_reset_tokens.sql` | Password reset + email verification tokens |

## Testing

```bash
mvn test                    # Run all unit tests
mvn verify                  # Run unit + integration tests
mvn test -pl backend        # From repo root
```

## Building the JAR

```bash
mvn clean package -DskipTests
java -jar target/propvault-backend-1.0.0-SNAPSHOT.jar
```
